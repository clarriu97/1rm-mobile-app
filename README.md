# 🏋️ One Rep Max Tracker

> *Because the only thing better than a new PR is a beautiful app to log it.*

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square&logo=githubactions&logoColor=white)](https://github.com/carlos/one_rm_mobile/actions)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.11-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)

[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-blue?style=flat-square)]()
[![Code Style](https://img.shields.io/badge/code%20style-flutter_lints-8B5CF6?style=flat-square)]()

[![Lifts](https://img.shields.io/badge/lifts-heavy-FF6B6B?style=flat-square)]()
[![Reps](https://img.shields.io/badge/reps-for%20days-FFA94D?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-FF69B4?style=flat-square)]()

---

## 💪 What is this?

A cross-platform Flutter app to **calculate, track, and obsess over your One-Rep Max** — the heaviest weight you can move exactly once. Log sets with weight and reps, and let the [Epley formula](#-the-science) do the math.

![Home Screen](https://img.shields.io/badge/screenshot-coming%20soon-lightgrey?style=social)

## 🎯 Features

- **12 built-in exercises** — Back Squat, Bench Press, Deadlift, and 9 more
- **Epley 1RM calculation** — enter weight × reps, get your estimated max
- **Percentage working-weight table** — 50–100% in 5% steps, rounded to nearest 1 kg
- **Dark theme** — because you lift in the dungeon, not a tanning bed
- **Per-exercise history** — chronologically sorted with relative dates
- **Delete entries** — long-press to yeet that failed set into oblivion
- **Comma & dot decimal support** — `112,5` kg works just like `112.5`
- **2 platforms** — Android & iOS

## 🔬 The Science

The app uses the **Epley Formula** — one of the most widely used 1RM estimation equations:

```
1RM = weight × (1 + reps / 30)
```

> For reps ≤ 1, the raw weight is returned as the 1RM.

Working weights are rounded to the nearest **1 kg**.

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/one_rm_mobile.git
cd one_rm_mobile

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

## 🧪 Testing

```bash
# Run all tests with coverage
flutter test --coverage

# Check formatting
dart format --set-exit-if-changed .

# Static analysis
flutter analyze
```

## 🧰 Built With

| Tool | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [Dart](https://dart.dev) | Language |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Strict lint rules |
| [GitHub Actions](https://github.com/features/actions) | CI/CD |

## 🤝 Contributing

PRs are welcome! If you find a bug:

1. Write a test that reproduces it
2. Fix the code
3. Make sure all tests pass (`flutter test`)

The project follows strict lint rules — `dart format .` and `flutter analyze` must pass.

## 📄 License

MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <i>Log your lifts. Chase the gains. One rep at a time.</i><br>
  <img src="https://img.shields.io/badge/made%20with-%F0%9F%92%AA-purple?style=flat-square" alt="Made with love (and biceps)">
</p>
