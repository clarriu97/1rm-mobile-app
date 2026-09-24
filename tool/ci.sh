#!/usr/bin/env bash
# The checks CI runs, runnable locally with the same commands.
#
#   tool/ci.sh                 checks + goldens (goldens on macOS only)   ~1 min
#   tool/ci.sh all             the above + every e2e target available     ~5-10 min
#
#   tool/ci.sh checks          lint + unit
#   tool/ci.sh lint            format and analyze
#   tool/ci.sh unit            unit, widget and layout-matrix tests
#   tool/ci.sh goldens         pixel comparisons (macOS)
#   tool/ci.sh boot-ios SIZE   boot the simulator for SIZE (small|large), print its id
#   tool/ci.sh e2e-ios SIZE    e2e flows on that simulator (boots it if needed)
#   tool/ci.sh e2e-android     e2e flows on the running Android emulator/device
set -euo pipefail

cd "$(dirname "$0")/.."

E2E=integration_test/app_test.dart

# Safety net for a run stuck before the build finishes. A healthy run takes
# 3 min locally and up to ~12 min on a slow CI runner; hangs after the build
# are caught much sooner by STALL_TIMEOUT.
E2E_TIMEOUT=${E2E_TIMEOUT:-1500}

# Once the app is built, flutter prints something at least every ~60 s (each
# finished test on CI, progress locally). Silence this long means the tool is
# stuck attaching to the app.
STALL_TIMEOUT=${STALL_TIMEOUT:-120}

step() { printf '\n\033[1;33m▶ %s\033[0m\n' "$*"; }

lint() {
  step "format"
  dart format --output=none --set-exit-if-changed .
  step "analyze"
  flutter analyze
}

unit() {
  step "unit, widget and layout-matrix tests"
  flutter test --exclude-tags golden
}

checks() {
  lint
  unit
}

goldens() {
  if [[ "$(uname)" != Darwin ]]; then
    echo "Goldens are generated on macOS; skipping on $(uname)."
    return
  fi
  step "goldens"
  flutter test --tags golden
}

# Runs the e2e flows on a device. Simulators and emulators occasionally fail
# to install or attach to the app before any test starts: they hang ("Error
# waiting for a debug connection") or the load fails ("Failed to start Dart
# Development Service"). A hung run is killed as soon as it is detected
# (silent after the build, or past E2E_TIMEOUT); either case is retried once.
# Once a test has run, a failure is real and is never retried.
run_e2e() {
  local device=$1 attempt status log pid tailer hung built size last_size last_change start
  for attempt in 1 2; do
    log=$(mktemp)
    flutter test "$E2E" -d "$device" >"$log" 2>&1 &
    pid=$!
    tail -n +1 -f "$log" &
    tailer=$!
    hung="" built="" last_size=0 last_change=$SECONDS start=$SECONDS
    while kill -0 "$pid" 2>/dev/null; do
      sleep 5
      size=$(wc -c <"$log")
      if ((size != last_size)); then
        last_size=$size last_change=$SECONDS
      fi
      if [[ -z "$built" ]] && grep -qE "Xcode build done|Built build/" "$log"; then
        built=1 last_change=$SECONDS
      fi
      if [[ -n "$built" ]] && ((SECONDS - last_change > STALL_TIMEOUT)); then
        hung="no output for ${STALL_TIMEOUT}s after the build"
      elif ((SECONDS - start > E2E_TIMEOUT)); then
        hung="still running after ${E2E_TIMEOUT}s"
      fi
      if [[ -n "$hung" ]]; then
        pkill -TERM -P "$pid" 2>/dev/null || true
        kill -TERM "$pid" 2>/dev/null || true
        break
      fi
    done
    status=0
    wait "$pid" || status=$?
    sleep 1
    kill "$tailer" 2>/dev/null || true
    wait "$tailer" 2>/dev/null || true
    if [[ -z "$hung" && "$status" -ne 0 ]] && grep -qE "Failed to load .*app_test\.dart" "$log"; then
      hung="the app failed to load before any test ran"
    fi
    rm -f "$log"
    if [[ -z "$hung" ]]; then
      return "$status"
    fi
    echo "⚠︎ e2e infrastructure failure ($hung) on attempt $attempt." >&2
  done
  return 1
}

# Newest available simulator whose name matches the size's pattern:
# small = iPhone SE / "e" models (narrowest), large = Pro Max.
ios_udid() {
  local pattern
  case "$1" in
    small) pattern='iPhone (SE|[0-9]+e)' ;;
    large) pattern='Pro Max' ;;
    *) echo "unknown size '$1' (small|large)" >&2; return 1 ;;
  esac
  xcrun simctl list devices available -j | jq -r --arg p "$pattern" '
    [.devices | to_entries[]
      | select(.key | test("iOS"))
      | .key as $rt | .value[]
      | select(.name | test($p)) | {rt: $rt, udid}]
    | sort_by(.rt) | last | .udid // empty'
}

boot_ios() {
  local udid
  udid=$(ios_udid "$1")
  if [[ -z "$udid" ]]; then
    echo "No $1 iPhone simulator available (Xcode → Settings → Components)." >&2
    return 1
  fi
  # Booting one that is already booting blocks for minutes; only boot it
  # when it is shut down.
  local state
  state=$(xcrun simctl list devices -j | jq -r --arg u "$udid" '.devices[][] | select(.udid == $u) | .state')
  if [[ "$state" == Shutdown ]]; then
    xcrun simctl boot "$udid"
  fi
  echo "$udid"
}

e2e_ios() {
  local udid
  # CI boots the simulator in an earlier step and passes its id along:
  # listing simulators while one boots can take minutes.
  udid=${SIM_UDID:-$(boot_ios "$1")}
  step "e2e on the $1 iPhone simulator ($udid)"
  xcrun simctl bootstatus "$udid" -b >/dev/null
  wait_for_log_stream "$udid"
  run_e2e "$udid"
}

# Flutter attaches to the app through the simulator's `log stream`, which on
# a freshly booted CI simulator can die right away ("The log reader failed
# unexpectedly"). Wait until a log stream stays up.
wait_for_log_stream() {
  local udid=$1 pid _
  for _ in $(seq 12); do
    xcrun simctl spawn "$udid" log stream --style compact >/dev/null 2>&1 &
    pid=$!
    sleep 5
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 0
    fi
    wait "$pid" 2>/dev/null || true
  done
  echo "⚠︎ the simulator's log stream never stayed up; trying anyway." >&2
}

android_device() {
  command -v adb >/dev/null || return 0
  adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }'
}

e2e_android() {
  local device
  device=$(android_device)
  if [[ -z "$device" ]]; then
    echo "No Android emulator or device running (start one from Android Studio → Device Manager)." >&2
    return 1
  fi
  # boot_completed can be set before the package manager accepts installs.
  local _
  for _ in $(seq 60); do
    adb -s "$device" shell pm path android >/dev/null 2>&1 && break
    sleep 2
  done
  step "e2e on Android $device"
  run_e2e "$device"
}

all() {
  checks
  goldens
  if [[ "$(uname)" == Darwin ]]; then
    e2e_ios small
    e2e_ios large
  fi
  if [[ -n "$(android_device)" ]]; then
    e2e_android
  else
    echo "⚠︎ Android e2e skipped: no emulator running. CI still runs it."
  fi
}

case "${1:-}" in
  "") checks; goldens ;;
  all) all ;;
  checks) checks ;;
  lint) lint ;;
  unit) unit ;;
  goldens) goldens ;;
  boot-ios) boot_ios "${2:?size: small|large}" ;;
  e2e-ios) e2e_ios "${2:?size: small|large}" ;;
  e2e-android) e2e_android ;;
  *) sed -n '2,13p' "$0"; exit 1 ;;
esac
