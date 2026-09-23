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

```bash
# Everything that runs without a device (what CI's test job runs, plus goldens on macOS)
flutter test

# Style and static analysis (CI fails on either)
dart format --set-exit-if-changed .
flutter analyze

# Goldens: compare, or regenerate after an intentional visual change (macOS)
flutter test --tags golden
flutter test --update-goldens --tags golden

# End-to-end on a simulator, emulator or device
flutter devices                              # list ids
flutter test integration_test -d <device-id>
```

To pick a specific screen size: `xcrun simctl list devices available` (iOS) or create an emulator in Android Studio → Device Manager, then pass its id to `-d`.

### CI

Every pull request runs:
- **Flutter CI**: format + analyze, unit/widget/matrix tests (Linux), goldens (macOS).
- **E2E**: all `integration_test/` flows on the smallest and largest current iPhone simulators (macOS) and on Android emulators with API 24 on a small screen and API 35 on a large one (Linux).

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
