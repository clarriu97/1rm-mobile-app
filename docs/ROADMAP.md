# Roadmap and project state

The entry point for anyone (human or agent) picking up the project: where it
stands, what was decided and why, and what comes next. Loaded into every
Claude Code session through `CLAUDE.md`. **Keep it current**: the pull request
that finishes a milestone, makes a decision or changes where something lives
updates this file too.

GitHub is the source of truth for tasks: issues, milestones and PRs in
`clarriu97/1rm-mobile-app`. This file summarizes and links; it never
duplicates issue bodies.

```bash
gh issue list --milestone "M4 · Calidad de lanzamiento"      # open work of a milestone
gh issue view <n>                                           # full scope of an issue
gh pr list                                                  # anything in flight
gh run list --workflow e2e.yml --branch main --limit 3      # e2e health on main
```

## Product

1RM: estimate, log and track one-rep maxes, used in the gym between sets.
Offline-first, no backend, no accounts, data stays on the device. iPhone and
Android (phones; Android tablets must not break). Owner: Carlos Larriu
(`clarriu97`).

## Phases and milestones

| Milestone | Status | What it delivered / delivers |
|---|---|---|
| M1 · Cimientos | ✅ done | Repository that persists on every change, stable exercise ids + versioned file with migration, atomic saves, tests mirroring `lib/` |
| M2 · Identidad visual | ✅ done | Industrial/gym design system (tokens, Big Shoulders + Barlow), generated exercise icons and illustrations, app icon, splash, "1RM" name |
| M3 · UX principal | ✅ done | Home cards with best 1RM + sparkline, live 1RM on add entry with dates, PR celebration, progress chart, %/reps tables, editable history with undo, 34-lift library with custom lifts and hiding, onboarding with kg/lbs and lift picking |
| M3.5 · Testing en dispositivos | ✅ done | iPhone-only, layout matrix, goldens, e2e flows in CI |
| **M4 · Calidad de lanzamiento** | **🔜 current** | #16 i18n es/en (done) → #55 rename/delete custom lifts (done) → #17 accessibility → #18 motion → #20 release config → #19 CI release builds (#51, local e2e gate, done). Issue bodies include testing follow-ups added on 2026-09-23 |
| Fase 2 · Publicación | later | Store accounts, TestFlight/Play, real devices on Firebase Test Lab (#45), screenshots, ASO, monetization |
| Post-v1 | backlog | #21: backup export/import, plate calculator, formula choice, light mode |

**Next step:** M4 in the order above, continuing with #17. Work one issue per
branch and PR, following AGENTS.md → Workflow.

## Decisions (newest first)

- **2026-09-24 · Localization (#16).** Strings in `lib/l10n/app_{en,es}.arb`
  (gen-l10n; generated Dart committed next to them); exercise and family names
  by stable id in `lib/l10n/localized_names.dart`. Numbers follow the language
  (`116,7 kg` in Spanish), "reps" in both languages. Search in Manage
  exercises matches the Spanish and the English name, and a new exercise may
  repeat neither. The app follows the device language (English for any
  language other than Spanish) unless the user picks one in Settings (Same as
  device / English / Español), saved in preferences. The small iPhone runs
  the e2e flows in Spanish, the large one in English (`tool/ci.sh`); flows
  find text through `AppLocalizations`.

- **2026-09-24 · Merge gate.** Pull requests run only deterministic checks
  (`analyze`, `test`, `goldens`). The e2e flows run locally through
  `tool/ci.sh all`, which reports the required `local-e2e` status, and on
  GitHub after every merge, nightly and for releases. Reason: GitHub's
  simulators/emulators fail to attach to the app in about half the iOS jobs,
  which says nothing about the code (#51, docs/RELEASING.md).
- **2026-09-24 · No build caches in CI.** Measured: Xcode/Gradle artifact caches
  cost as much as they save. CocoaPods removed (every plugin is a Swift
  package). Hung simulator runs are detected and retried once (#50).
- **2026-09-24 · Contact and site.** Support/privacy contact
  `info.1rm@larri.dev` (Cloudflare Email Routing to the owner's inbox). Website
  https://1rm.larri.dev with `/privacy/` and `/terms/`; the About screen (#20)
  links there.
- **2026-09-23 · Exercise names in Spanish (#16).** Translate gym classics
  (Sentadilla trasera, Press de banca, Peso muerto rumano, Dominadas
  lastradas…); keep Olympic and CrossFit names in English as boxes use them
  (Clean & Jerk, Snatch, Thruster, Push Press…).
- **2026-09-23 · iPhone only on iOS** (#41). Portrait lock comes with #20;
  Android tablets can still rotate (Android 16 ignores the lock on large
  screens), so the layout matrix keeps a landscape tablet.
- **2026-09-23 · Test strategy.** Unit + widget tests, a layout matrix (8
  devices × text 100/130/200 %), goldens on macOS with a tolerant comparator,
  and e2e flows with real storage. Flutter is pinned (`FLUTTER_VERSION` in the
  workflows) so goldens are reproducible.
- **2026-09-23 · Library.** 34 lifts in 7 families; 10 visible by default;
  onboarding lets users pick theirs; hiding keeps records.
- **2026-09-23 · v1 scope.** Progress chart and PRs, plus what a lifter really
  needs (past dates, editing, live estimate, unit choice). Every addition must
  pass "would a real user need this?".
- **2026-09-23 · Languages** English + Spanish, following the system language
  (a Settings override was added on 2026-09-24, #16).
- **2026-09-23 · Visual direction** industrial / gym: dark iron and chalk,
  condensed display type, one safety-yellow accent. Clarity wins over
  decoration.
- **2026-09-23 · Architecture.** Layered, no state-management packages:
  services → `ChangeNotifier` repositories → screens with
  `ListenableBuilder`. Weights stored in kg, exercises keyed by stable id,
  records file carries `schemaVersion` (currently 2).
- **Phase 2 caveat:** adding ads or analytics changes what the app collects:
  the privacy policy, the store privacy labels and possibly a consent flow must
  change with them.

## Where things live

| What | Where |
|---|---|
| App code | this repo; architecture and rules in AGENTS.md |
| Testing gates, releasing | docs/RELEASING.md, `tool/ci.sh` |
| Design references | `docs/design/*.jpg`, goldens in `test/goldens/goldens/` |
| Icon and illustration generators | `tool/generate_icons.py`, `tool/generate_branding.py` |
| Landing page | repo `clarriu97/1rm-landing-page` (static Vite + Tailwind, deployed by Cloudflare on push to `main`), live at https://1rm.larri.dev |
| Contact address | `info.1rm@larri.dev` |
| App ids | bundle id / applicationId `dev.larri.onerm`, display name "1RM" |
| CI | `.github/workflows/`: `flutter.yml` (PR checks), `e2e.yml` (main, nightly, releases), `release.yml` (`v*` tags) |
| Branch protection | `main`: required `analyze`, `test`, `goldens`, `local-e2e`; up to date with main; linear history; applies to admins |
