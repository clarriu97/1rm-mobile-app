## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

In every iteration or new feature, you must automatically run dart format ., flutter analyze, and flutter test. If any linter rule or test fails, you must iterate and fix the code autonomously before considering the task complete.

## Testing (paranoid mindset)

You must adopt a testing-paranoid mindset for every single change:

1. Every new function, widget, or behavior must have corresponding unit/widget/integration tests written before or alongside the implementation.
2. Edge cases are not optional — you must explicitly test for: null/empty inputs, zero values, boundary values (e.g. 1 rep, 0 weight, maximum reasonable inputs), negative numbers where applicable, and any branching logic.
3. Before modifying any existing code, first check if existing tests cover the change. If not, add tests first.
4. After any change, always run the full test suite. A partial pass is a failure.
5. If a bug is discovered, first write a test that reproduces the bug, then fix the code to make the test pass.
6. Never assume input validation is handled elsewhere — test at the boundary of every unit.
7. UI tests must verify both happy paths (valid data produces correct output) and sad paths (invalid/empty data shows appropriate feedback).
8. Flaky tests are not acceptable. If a test is non-deterministic, fix it immediately.

## Skill-driven testing

A flutter-testing skill is installed with detailed reference docs for each test layer. You must follow its workflow and conventions for all test work:

- **Choose the right layer**: unit tests for pure Dart logic (repositories, services, state, view models); widget tests for widgets, forms, navigation, semantics, gestures, and UI state; integration tests for complete user flows, real device behavior, screenshots, and native/plugin bridges.
- **Read the relevant reference before writing tests**: `.agents/skills/flutter-testing/references/unit-testing.md`, `.agents/skills/flutter-testing/references/widget-testing.md`, `.agents/skills/flutter-testing/references/integration-testing.md`, `.agents/skills/flutter-testing/references/mocking.md`, `.agents/skills/flutter-testing/references/common-errors.md`, or `.agents/skills/flutter-testing/references/plugin-testing.md` as appropriate.
- **Use the project's existing style**: dependency injection patterns, keys, fixtures, mocks, and CI constraints. Do not invent new patterns.
- **Prefer `flutter_test`** for widget/integration tests; use `package:test/test.dart` only for pure Dart tests without Flutter bindings.
- **No fixed `Future.delayed`** to hide async uncertainty. Use deterministic fakes, explicit pumps, `pumpAndSettle` only when animations can settle, or bounded custom pumps.
- **Retrofit old tests**: when you encounter existing tests that deviate from these skill conventions (e.g. missing edge cases, hardcoded delays, testing private internals, wrong test layer), update them to align with the skill guidelines. Do not leave inconsistent test patterns behind.

## Skill-driven design, UI/UX, and animations

Two design-oriented skills are installed: **frontend-design** for UI/UX and visual identity, and **flutter-animations** for motion and transitions. When any design, UI/UX, or animation work is needed:

### UI/UX design (frontend-design skill)

Before coding any UI, commit to a bold, intentional aesthetic direction:

- **Define the tone**: choose a clear conceptual direction (brutally minimal, maximalist, retro-futuristic, organic, luxury, playful, editorial, brutalist, art deco, industrial, etc.) and execute it with precision.
- **Typography**: avoid generic fonts (Inter, Roboto, Arial). Use distinctive, characterful font pairings — a display font with a refined body font.
- **Color & theme**: commit to a cohesive palette with dominant colors and sharp accents. Avoid timid, evenly-distributed palettes and overused purple-on-white gradients.
- **Spatial composition**: use unexpected layouts, asymmetry, overlap, diagonal flow, generous negative space or controlled density. Break the grid intentionally.
- **Backgrounds & visual details**: create atmosphere with textures, gradients, noise, geometric patterns, layered transparencies, dramatic shadows, and decorative elements. Never default to solid colors.
- **Differentiation**: every screen should have one memorable, unforgettable element. Do not produce cookie-cutter designs.

### Animations (flutter-animations skill)

- **Inspect context first**: widget tree, state management, navigation, theming, accessibility helpers, and existing animation abstractions before adding anything.
- **Choose the minimal model**: implicit animations for simple property changes; explicit controllers only when lifecycle control, gestures, or coordinated multi-property motion is required; Hero for shared-element route transitions; staggered for sequenced reveals; physics for velocity/spring/fling behavior.
- **Read the relevant reference before coding**: `.agents/skills/flutter-animations/references/implicit.md`, `.agents/skills/flutter-animations/references/explicit.md`, `.agents/skills/flutter-animations/references/hero.md`, `.agents/skills/flutter-animations/references/staggered.md`, `.agents/skills/flutter-animations/references/physics.md`, or `.agents/skills/flutter-animations/references/curves.md`.
- **Respect accessibility**: check `MediaQuery.disableAnimations` or existing reduced-motion policy, and provide a static fallback when motion can distract or harm usability.
- **Follow lifecycle discipline**: controllers owned by the state object that owns the animation, disposed properly, never created inside build methods.
- **Validate**: run `dart format`, `flutter analyze`, and focused tests whenever animation changes affect navigation, gestures, or stateful lifecycle.
