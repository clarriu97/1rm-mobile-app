#!/usr/bin/env bash
# The checks CI runs, runnable locally with the same commands.
#
#   tool/ci.sh                 checks + goldens (goldens on macOS only)   ~1 min
#   tool/ci.sh all             the above + release builds + e2e on every
#                              target available                          ~7-11 min
#                              and, when it all passes on a pushed commit
#                              with no local changes, reports the
#                              `local-e2e` status that merging into main needs
#   tool/ci.sh report          report `local-e2e` for HEAD after pushing, if
#                              `tool/ci.sh all` already passed on it
#
#   tool/ci.sh checks          lint + unit
#   tool/ci.sh lint            format and analyze
#   tool/ci.sh unit            unit, widget and layout-matrix tests
#   tool/ci.sh goldens         pixel comparisons (macOS)
#   tool/ci.sh boot-ios SIZE   boot the simulator for SIZE (small|large), print its id
#   tool/ci.sh e2e-ios SIZE    e2e flows on that simulator (boots it if needed),
#                              in Spanish on the small one, English on the large
#   tool/ci.sh e2e-android     e2e flows on an Android emulator (starts one if needed)
#   tool/ci.sh smoke-android-release  launch the release (R8) build on an
#                              emulator: first run, storage, relaunch
#   tool/ci.sh build-android   release app bundle (R8), as the store gets it
#   tool/ci.sh build-ios       release iOS build without code signing
set -euo pipefail

cd "$(dirname "$0")/.."

E2E=integration_test/app_test.dart

# Where `tool/ci.sh all` remembers the commits it passed on.
STAMPS=.dart_tool/local-e2e

# Set by e2e_android: the API level it ran on.
ANDROID_API=""

# Android SDK tools, installed by Android Studio.
ANDROID_HOME=${ANDROID_HOME:-$HOME/Library/Android/sdk}
for dir in "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator"; do
  if [[ -d "$dir" ]]; then PATH="$dir:$PATH"; fi
done

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
  # CI sets COVERAGE=1 and uploads coverage/lcov.info.
  flutter test --exclude-tags golden ${COVERAGE:+--coverage}
  if [[ -n "${COVERAGE:-}" ]]; then coverage_summary; fi
}

# Line coverage of lib/ from coverage/lcov.info, generated code excluded.
coverage_summary() {
  awk -F: '
    /^SF:/ { skip = ($2 ~ /lib\/l10n\/app_localizations/) }
    /^LF:/ && !skip { found += $2 }
    /^LH:/ && !skip { hit += $2 }
    END { printf "Line coverage: %.1f %% (%d of %d lines)\n", 100 * hit / found, hit, found }
  ' coverage/lcov.info
}

build_android() {
  step "release app bundle"
  flutter build appbundle --release
}

build_ios() {
  step "release iOS build (no code signing)"
  flutter build ios --release --no-codesign
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
    # "Failed to load" also covers a failed build, which is real: only a
    # load failure after a successful build is the device's fault.
    if grep -qE "Xcode build done|Built build/" "$log"; then
      built=1
    fi
    if [[ -z "$hung" && "$status" -ne 0 && -n "$built" ]] && grep -qE "Failed to load .*app_test\.dart" "$log"; then
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

# The small iPhone runs the flows in Spanish: its longer text on the narrowest
# screen is where layouts break. The large one runs them in English.
ios_language() {
  case "$1" in
    small) echo es ;;
    *) echo en ;;
  esac
}

e2e_ios() {
  local udid was_booted="" status=0 language
  if [[ -z "${SIM_UDID:-}" ]]; then
    udid=$(ios_udid "$1")
    if xcrun simctl list devices | grep "$udid" | grep -q Booted; then
      was_booted=1
    fi
  fi
  # CI boots the simulator in an earlier step and passes its id along:
  # listing simulators while one boots can take minutes.
  udid=${SIM_UDID:-$(boot_ios "$1")}
  language=$(ios_language "$1")
  step "e2e on the $1 iPhone simulator ($udid), in $language"
  xcrun simctl bootstatus "$udid" -b >/dev/null
  # Apps launched from now on read it; the region stays as it was.
  xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "$language"
  wait_for_log_stream "$udid"
  run_e2e "$udid" || status=$?
  # Shut down what this run booted; leave a simulator you had open.
  if [[ -z "${SIM_UDID:-}" && -z "$was_booted" ]]; then
    xcrun simctl shutdown "$udid" 2>/dev/null || true
  fi
  return "$status"
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

# Prints a running Android device, starting an emulator (the first AVD whose
# name contains "1rm", else the first one) when none is running. Prints
# nothing when there is no emulator to start.
boot_android() {
  local device avd _
  device=$(android_device)
  if [[ -z "$device" ]] && command -v emulator >/dev/null; then
    avd=$(emulator -list-avds 2>/dev/null | grep -i 1rm | head -1 || true)
    [[ -z "$avd" ]] && avd=$(emulator -list-avds 2>/dev/null | head -1 || true)
    if [[ -n "$avd" ]]; then
      echo "Starting Android emulator $avd..." >&2
      emulator -avd "$avd" -no-window -no-audio -no-boot-anim -no-snapshot-save >/dev/null 2>&1 &
      adb wait-for-device
      for _ in $(seq 90); do
        [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == 1 ]] && break
        sleep 2
      done
      device=$(android_device)
    fi
  fi
  echo "$device"
}

# True when there is an Android device running or an emulator to start.
android_available() {
  [[ -n "$(android_device)" ]] ||
    { command -v emulator >/dev/null && [[ -n "$(emulator -list-avds 2>/dev/null)" ]]; }
}

e2e_android() {
  local device was_running status=0
  was_running=$(android_device)
  device=$(boot_android)
  if [[ -z "$device" ]]; then
    echo "No Android emulator available: create one in Android Studio → Device Manager." >&2
    return 1
  fi
  # boot_completed can be set before the package manager accepts installs.
  local _
  for _ in $(seq 60); do
    adb -s "$device" shell pm path android >/dev/null 2>&1 && break
    sleep 2
  done
  ANDROID_API=$(adb -s "$device" shell getprop ro.build.version.sdk | tr -d '\r')
  step "e2e on Android $device (API $ANDROID_API)"
  run_e2e "$device" || status=$?
  # Stop the emulator this run started; leave one you had open.
  if [[ -z "$was_running" ]]; then
    adb -s "$device" emu kill >/dev/null 2>&1 || true
  fi
  return "$status"
}

# Polls the screen of $1 until an element's text or description starts
# with $2 (a regex); prints its centre ("x y"). Fails after 60 s.
android_find() {
  local device=$1 pattern=$2 bounds _
  for _ in $(seq 30); do
    bounds=$(adb -s "$device" exec-out uiautomator dump /dev/tty 2>/dev/null |
      tr '>' '\n' | grep -E "(text|content-desc)=\"($pattern)" |
      grep -oE 'bounds="\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\]"' | head -1 || true)
    if [[ -n "$bounds" ]]; then
      echo "$bounds" | tr -c '0-9' ' ' | awk '{ print int(($1 + $3) / 2), int(($2 + $4) / 2) }'
      return 0
    fi
    sleep 2
  done
  echo "Never showed: $pattern" >&2
  return 1
}

# The e2e flows need `flutter test`, which only runs debug builds, and
# `flutter drive` refuses release mode. So the release build (AOT + R8) gets a
# smoke test instead: the first run shows onboarding, skipping reaches Home,
# and after a relaunch Home comes back. That covers what R8 breaks first:
# plugins (preferences, file storage) and the app starting at all.
smoke_android_release() {
  local device was_running app=dev.larri.onerm status=0 at
  was_running=$(android_device)
  device=$(boot_android)
  if [[ -z "$device" ]]; then
    echo "No Android emulator available." >&2
    return 1
  fi
  local _
  for _ in $(seq 60); do
    adb -s "$device" shell pm path android >/dev/null 2>&1 && break
    sleep 2
  done
  step "release smoke test on Android $device"
  flutter build apk --release
  {
    adb -s "$device" install -r build/app/outputs/flutter-apk/app-release.apk >/dev/null &&
      adb -s "$device" shell pm clear "$app" >/dev/null &&
      adb -s "$device" logcat -c &&
      adb -s "$device" shell am start -n "$app/.MainActivity" >/dev/null &&
      at=$(android_find "$device" "Skip|Saltar") &&
      adb -s "$device" shell input tap $at &&
      android_find "$device" "Back Squat|Sentadilla trasera" >/dev/null &&
      adb -s "$device" shell am force-stop "$app" &&
      adb -s "$device" shell am start -n "$app/.MainActivity" >/dev/null &&
      android_find "$device" "Back Squat|Sentadilla trasera" >/dev/null
  } || status=1
  if adb -s "$device" logcat -d | grep -E "FATAL EXCEPTION|MissingPluginException"; then
    status=1
  fi
  if [[ -z "$was_running" ]]; then
    adb -s "$device" emu kill >/dev/null 2>&1 || true
  fi
  if ((status == 0)); then echo "Release build OK."; fi
  return "$status"
}

all() {
  local passed="" sha
  sha=$(git rev-parse HEAD)
  checks
  goldens
  if [[ -d "$ANDROID_HOME" ]]; then
    build_android
  else
    echo "⚠︎ Android release build skipped: no Android SDK. CI builds it on main."
  fi
  if [[ "$(uname)" == Darwin ]]; then
    build_ios
    e2e_ios small
    e2e_ios large
    passed="iOS small, iOS large"
  fi
  if android_available; then
    e2e_android
    passed="${passed:+$passed, }Android API $ANDROID_API"
  else
    echo "⚠︎ Android e2e skipped: no emulator. CI runs it on main."
    passed="${passed:+$passed; }Android skipped"
  fi
  if [[ -n "$(git status --porcelain)" || "$(git rev-parse HEAD)" != "$sha" ]]; then
    echo "⚠︎ Not recording a pass: the tests ran on uncommitted changes." >&2
    return 0
  fi
  mkdir -p "$STAMPS"
  echo "e2e passed locally: $passed" >"$STAMPS/$sha"
  report
}

# Reports the `local-e2e` commit status for HEAD on GitHub, which the main
# branch protection requires before merging. Only for a commit that
# `tool/ci.sh all` passed on, with no local changes, once it is pushed.
report() {
  local sha repo stamp
  sha=$(git rev-parse HEAD)
  stamp="$STAMPS/$sha"
  if [[ ! -f "$stamp" ]]; then
    echo "tool/ci.sh all has not passed on $sha; run it first." >&2
    return 1
  fi
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Local changes on top of $sha; commit or stash them first." >&2
    return 1
  fi
  git fetch -q origin 2>/dev/null || true
  if [[ -z "$(git branch -r --contains "$sha" 2>/dev/null)" ]]; then
    echo "⚠︎ $sha is not pushed yet: push it, then run tool/ci.sh report." >&2
    return 0
  fi
  repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
  gh api -X POST "repos/$repo/statuses/$sha" \
    -f state=success -f context=local-e2e \
    -f description="$(head -c 140 "$stamp")" >/dev/null
  step "local-e2e reported on $sha: $(cat "$stamp")"
}

case "${1:-}" in
  "") checks; goldens ;;
  all) all ;;
  report) report ;;
  checks) checks ;;
  lint) lint ;;
  unit) unit ;;
  goldens) goldens ;;
  boot-ios) boot_ios "${2:?size: small|large}" ;;
  e2e-ios) e2e_ios "${2:?size: small|large}" ;;
  e2e-android) e2e_android ;;
  smoke-android-release) smoke_android_release ;;
  build-android) build_android ;;
  build-ios) build_ios ;;
  *) sed -n '2,23p' "$0"; exit 1 ;;
esac
