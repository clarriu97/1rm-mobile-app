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

# A healthy e2e run (build + install + flows) takes under 7 min on CI and
# 3 min locally; past this, it is hung.
E2E_TIMEOUT=${E2E_TIMEOUT:-600}

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

# Runs the e2e flows on a device. Simulators and emulators occasionally hang
# while installing or attaching to the app; such a run is killed after
# E2E_TIMEOUT seconds and retried once. A failing test is never retried.
run_e2e() {
  local device=$1 attempt status marker pid watchdog
  for attempt in 1 2; do
    marker=$(mktemp -u)
    flutter test "$E2E" -d "$device" &
    pid=$!
    (sleep "$E2E_TIMEOUT" && touch "$marker" && pkill -TERM -P "$pid"; kill -TERM "$pid") >/dev/null 2>&1 &
    watchdog=$!
    status=0
    wait "$pid" || status=$?
    # Stop the watchdog and its sleep, which would otherwise outlive us.
    pkill -P "$watchdog" 2>/dev/null || true
    kill "$watchdog" 2>/dev/null || true
    wait "$watchdog" 2>/dev/null || true
    if [[ ! -f "$marker" ]]; then
      return "$status"
    fi
    rm -f "$marker"
    echo "⚠︎ e2e hung for ${E2E_TIMEOUT}s on attempt $attempt; killed." >&2
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
  xcrun simctl boot "$udid" 2>/dev/null || true # already booted is fine
  echo "$udid"
}

e2e_ios() {
  local udid
  udid=$(boot_ios "$1")
  step "e2e on $(xcrun simctl list devices | grep "$udid" | sed 's/ (.*//;s/^ *//') ($1)"
  xcrun simctl bootstatus "$udid" -b >/dev/null
  # Flutter attaches to the app through the simulator's log stream, which on
  # a freshly booted CI simulator can fail on first use ("The log reader
  # failed unexpectedly"); touch it once before the real run.
  xcrun simctl spawn "$udid" log show --last 1m --style compact >/dev/null 2>&1 || true
  run_e2e "$udid"
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
