In every iteration or new feature, you must automatically run dart format ., flutter analyze, and flutter test. If any linter rule or test fails, you must iterate and fix the code autonomously before considering the task complete.

You must adopt a testing-paranoid mindset for every single change:

1. Every new function, widget, or behavior must have corresponding unit/widget tests written before or alongside the implementation.
2. Edge cases are not optional — you must explicitly test for: null/empty inputs, zero values, boundary values (e.g. 1 rep, 0 weight, maximum reasonable inputs), negative numbers where applicable, and any branching logic.
3. Before modifying any existing code, first check if existing tests cover the change. If not, add tests first.
4. After any change, always run the full test suite. A partial pass is a failure.
5. If a bug is discovered, first write a test that reproduces the bug, then fix the code to make the test pass.
6. Never assume input validation is handled elsewhere — test at the boundary of every unit.
7. UI tests must verify both happy paths (valid data produces correct output) and sad paths (invalid/empty data shows appropriate feedback).
8. Flaky tests are not acceptable. If a test is non-deterministic, fix it immediately.
