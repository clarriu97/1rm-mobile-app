# One Rep Max Tracker

> *Because the only thing better than a new PR is a beautiful app to log it.*

[![Build Status](https://img.shields.io/github/actions/workflow/status/clarriu97/1rm-mobile-app/flutter.yml?style=flat-square&logo=githubactions&logoColor=white)](https://github.com/clarriu97/1rm-mobile-app/actions)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.11-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-blue?style=flat-square)]()
[![Code Style](https://img.shields.io/badge/code%20style-flutter_lints-8B5CF6?style=flat-square)]()

---

## What is this?

A cross-platform Flutter app to **calculate, track, and obsess over your One-Rep Max** — the heaviest weight you can move exactly once. Log sets with weight and reps, and let the [Epley formula](#-the-science) do the math.

## Features

- **34 lifts** — squat, hinge, bench, overhead, pulls, Olympic lifts and CrossFit staples (thruster, cluster, SDHP…), each with its own vector icon; show only the ones you train, or add your own
- **Live 1RM estimate** — type weight × reps and see the Epley estimate before saving; log past sessions with a date picker
- **Personal records** — beating your best triggers a celebration; PRs are badged in the history
- **Progress chart** — 1RM over time per lift, 3M / 1Y / ALL
- **Working weights** — percentage table (50–100 %) and reps table (1–10), rounded to loadable plates (1 kg / 5 lbs)
- **Editable history** — grouped by month; tap to edit, swipe to delete, undo
- **kg / lbs** — chosen at onboarding (default from your region), switchable in Settings; data is stored in kg
- **Offline and private** — everything stays on the device, saved on every change
- **Dark industrial theme**, iPhone and Android

## The Science

The app uses the **Epley Formula** — one of the most widely used 1RM estimation equations:

```
1RM = weight × (1 + reps / 30)
```

> For reps ≤ 1, the raw weight is returned as the 1RM.

Working weights are rounded to the nearest **1 kg**.

## Getting Started

```bash
# Clone the repository
git clone https://github.com/clarriu97/1rm-mobile-app.git
cd 1rm-mobile-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Run on a specific platform

```bash
flutter run -d ios     # iOS (macOS only)
flutter run -d android # Android
```

## Testing

| Kind | Where | What it covers | Runs on |
|---|---|---|---|
| **Unit** | `test/` (`test()`) | Pure logic: formulas, rounding, kg ↔ lbs, repositories, storage migrations | Host machine, milliseconds |
| **Widget** | `test/` (`testWidgets`) | One screen rendered by the real Flutter framework: tap, type, scroll, check what shows | Host machine, no device |
| **Layout matrix** | `test/ui/layout_matrix_test.dart` | Every screen × 8 devices (iPhone SE → Android tablet) × text 100 / 130 / 200 %; fails on any overflow | Host machine |
| **Golden** | `test/goldens/` (tag `golden`) | Pixel comparison of the key screens against checked-in PNGs | macOS only |
| **End-to-end** | `integration_test/` | Full user flows on a simulator/emulator with real disk storage, including app relaunch and the iOS back swipe | Simulator, emulator or device |

Flutter draws every pixel itself, so widget tests exercise the same layout code a phone runs. The end-to-end tests add what they can't see: plugins (storage, preferences), the real engine, back gestures and cold starts.

The same commands CI runs are wrapped in `tool/ci.sh`, so a local run is identical to CI:

```bash
tool/ci.sh                  # format, analyze, unit/widget/matrix tests, goldens (~1 min)
tool/ci.sh all              # + e2e on the small and large iPhone simulators and an Android emulator; reports local-e2e
tool/ci.sh e2e-ios small    # one e2e target: small | large
tool/ci.sh e2e-android      # e2e on the running emulator/device
```

Run the fast checks automatically before every push (once per clone):

```bash
git config core.hooksPath tool/git-hooks   # then: E2E=1 git push to include the e2e flows
```

Lower-level commands:

```bash
flutter test --exclude-tags golden               # unit, widget, layout matrix
flutter test --update-goldens --tags golden      # regenerate screenshots after a visual change (macOS)
flutter devices                                  # list simulator/emulator/device ids
flutter test integration_test/app_test.dart -d <device-id>
```

**Android locally**: builds use JDK 17, like CI (Android Studio bundles a newer Java that the project's Gradle doesn't support yet). Once, after installing Android Studio and its SDK Command-line Tools:

```bash
brew install openjdk@17
flutter config --jdk-dir "$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
```

Create the emulators the gate uses, matching CI (API 24 small screen, API 35 large screen); `tool/ci.sh all` starts the first AVD whose name contains `1rm` and stops it afterwards:

```bash
android sdk install "system-images/android-24/default/arm64-v8a" "system-images/android-35/google_apis/arm64-v8a"
avdmanager create avd -n 1rm_api24_small -k "system-images;android-24;default;arm64-v8a" -d "Nexus 5"
avdmanager create avd -n 1rm_api35_large -k "system-images;android-35;google_apis;arm64-v8a" -d "pixel_7"
```

All e2e flows live in `integration_test/flows/` and run from the single entry point `integration_test/app_test.dart`, so the app is built and installed once per run.

### CI and the merge gate

- **Every pull request** (~2 min): format + analyze, unit/widget/matrix tests (Linux), goldens (macOS).
- **Before merging**: `tool/ci.sh all` runs the e2e flows locally and reports the `local-e2e` status on the commit; `main` requires it.
- **After every merge, nightly and for every `v*` tag**: the e2e flows on the smallest and largest current iPhone simulators and on Android emulators (API 24 small screen, API 35 large screen).

Why it's split this way, and how to release: [docs/RELEASING.md](docs/RELEASING.md).

## Built With

| Tool | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [Dart](https://dart.dev) | Language |
| [path_provider](https://pub.dev/packages/path_provider) | Persistent JSON storage |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Strict lint rules |
| [GitHub Actions](https://github.com/features/actions) | CI/CD |

## Contributing

PRs are welcome! If you find a bug:

1. Write a test that reproduces it
2. Fix the code
3. Make sure all tests pass (`flutter test`)

The project follows strict lint rules — `dart format .` and `flutter analyze` must pass.

## License

MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <i>Log your lifts. Chase the gains. One rep at a time.</i><br>
  <img src="https://img.shields.io/badge/made%20with-%F0%9F%92%AA-purple?style=flat-square" alt="Made with love (and biceps)">
</p>
