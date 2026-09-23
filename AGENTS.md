# 1RM — Agent guide

Flutter app (iOS + Android) to estimate, log, and track one-rep maxes. Offline-first, no backend, no accounts.
Goal of phase 1: a feature-complete, polished v1 ready for App Store / Play Store submission.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked. No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting. Match existing style.
- Remove imports/variables/functions that YOUR changes made unused; mention (don't delete) pre-existing dead code.
- Every changed line should trace directly to the task.

## 4. Goal-Driven Execution

Turn tasks into verifiable goals ("fix the bug" → "write a failing test, then make it pass") and loop until verified. For multi-step work, state a brief plan with a verification per step.

---

## Architecture

Layered, following the official Flutter architecture guide — without extra state-management packages.

```
lib/
  main.dart          # composition root: builds services/repositories, injects them
  models/            # immutable domain types (ExerciseRecord, WeightUnit, …)
  data/              # static data (default exercise library)
  services/          # I/O wrappers: file storage, SharedPreferences. Abstract class + `forTesting()` fake.
  repositories/      # single source of truth per domain, `ChangeNotifier`; persist on every mutation
  utils/             # pure functions (formulas, formatting)
  ui/<feature>/      # screens + widgets; listen to repositories via ListenableBuilder
  ui/theme/          # design tokens + ThemeData
  l10n/              # ARB files (en, es)
```

Rules:
- **Data flows down from repositories, never back up through `Navigator.pop` results.** Screens call repository methods; repositories persist immediately.
- Dependencies are injected through constructors from `main.dart`. No global singletons, no service locators.
- Weights are always stored in **kg**; convert only at the UI boundary (`formatWeight`, `lbsToKg`).
- Exercises are keyed by a **stable id** (`back_squat`), never by display name.
- Stored JSON carries a `schemaVersion`; any format change ships with a migration and a migration test.
- New dependencies need a clear justification in the PR. Prefer the SDK.

## UI / UX rules

The app is used in the gym, between sets: one hand, sweaty fingers, glancing at the screen.

- Tap targets ≥ 48 dp; primary actions in the thumb zone (bottom half).
- Key numbers (1RM, working weights) are big, high-contrast, tabular figures.
- Every user-visible string goes through `AppLocalizations` (en + es). No hardcoded strings in widgets.
- Colors, typography, spacing, and radii come from the theme tokens. No inline `Color(...)` / `TextStyle(...)` in screens.
- Respect platform conventions: iOS swipe-back must always work (never block pops to pass data), system text scaling up to 200 % must not overflow.
- Respect `MediaQuery.disableAnimations`: provide a static fallback for any non-trivial motion.
- Destructive actions are undoable (SnackBar "Undo") rather than confirmed with dialogs, where possible.
- Visual direction: **industrial / gym** — dark, iron-and-chalk, condensed display type, one strong accent. Distinctive, but clarity wins over decoration.

## Skills

Project skills live in `.claude/skills/` (`.agents` is a symlink for other agents). The official `dart-flutter` plugin (enabled in `.claude/settings.json`) adds Flutter/Dart skills and the Dart MCP server.

- Tests → `flutter-testing` (read the matching file in `.claude/skills/flutter-testing/references/` first); plugin skills `flutter-add-widget-test`, `flutter-add-integration-test`, `dart-add-unit-test`.
- Motion → `flutter-animations` (read `.claude/skills/flutter-animations/references/<type>.md` first).
- Visual design direction → `frontend-design` (principles only; it is web-oriented — translate to Flutter).
- Dart idioms → `dart-best-practices`. Layout bugs → `flutter-fix-layout-issues`. i18n → `flutter-setup-localization`.

## Testing (paranoid mindset)

1. Every new function, widget, or behavior ships with tests, written before or alongside the code.
2. Edge cases are mandatory: empty/null, zero, boundaries (1 rep, max reps, max weight), negatives, every branch.
3. Before modifying code, check existing coverage; add tests first if missing.
4. Bugs: first a test that reproduces it, then the fix.
5. UI tests cover happy paths and sad paths (invalid/empty input shows feedback).
6. Test layers: unit for pure Dart (repositories, services, formulas); widget for screens/forms/navigation/semantics; `integration_test/` for full user flows on simulator/device.
7. No `Future.delayed` to hide async timing. Use fakes, explicit pumps, `pumpAndSettle` only when animations settle. Flaky tests get fixed immediately.
8. Test files mirror `lib/` (`lib/repositories/records_repository.dart` → `test/repositories/records_repository_test.dart`). Reuse the services' `forTesting()` fakes; don't invent new mocking patterns.
9. When touching old tests that break these rules, bring them in line.

## Commands

```bash
flutter pub get
dart format .                      # CI runs: dart format --set-exit-if-changed .
flutter analyze
flutter test                       # full suite — a partial pass is a failure
flutter test integration_test      # on a running simulator/device
flutter devices
flutter run -d <device-id>         # iPhone (USB or Wi-Fi) or simulator; keep it running for hot reload
```

**Every change must pass `dart format .`, `flutter analyze`, and the full `flutter test` before it is considered done.** Iterate autonomously until green.

When the app is running (via `flutter run` or the Dart MCP server), hot reload after editing UI in `lib/`, and hot restart after changing `main()`, `initState`, or global/static state. Don't reload for edits outside `lib/` or comment-only changes.

## Workflow

- Work is tracked as GitHub issues in milestones (M1 Foundations → M4 Release quality).
- One branch per issue: `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `chore/<slug>`.
- Conventional commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `build:`, `ci:`).
- PR body contains `Closes #<issue>`, a summary, and how it was verified (tests + device screenshot for UI changes).
- Merge with squash once CI is green.
- Never commit secrets: `.env`, keystores, `key.properties`, and provisioning profiles stay out of git.
