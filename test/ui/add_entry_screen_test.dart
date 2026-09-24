import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('AddEntryScreen', () {
    testWidgets('renders form with exercise name in title', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddEntryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            unit: WeightUnit.kg,
          ),
        ),
      );

      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddEntryScreen(
            exerciseName: 'Test',
            assetPath: 'assets/icons/back_squat.svg',
            unit: WeightUnit.kg,
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsNWidgets(2));
    });

    testWidgets('pops with ExerciseRecord on calculate', (tester) async {
      ExerciseRecord? savedRecord;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Deadlift',
                      assetPath: 'assets/icons/deadlift.svg',
                      unit: WeightUnit.kg,
                    ),
                  ),
                );
                savedRecord = result;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '315');
      await tester.enterText(find.byType(TextFormField).at(1), '5');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedRecord, isNotNull);
      expect(savedRecord!.weight, 315);
      expect(savedRecord!.reps, 5);
      expect(savedRecord!.oneRM, closeTo(367.5, 0.1));
    });

    testWidgets('accepts comma decimal weight', (tester) async {
      ExerciseRecord? savedRecord;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Bench Press',
                      assetPath: 'assets/icons/bench_press.svg',
                      unit: WeightUnit.kg,
                    ),
                  ),
                );
                savedRecord = result;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '112,5');
      await tester.enterText(find.byType(TextFormField).at(1), '8');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedRecord, isNotNull);
      expect(savedRecord!.weight, closeTo(112.5, 0.01));
      expect(savedRecord!.reps, 8);
      expect(savedRecord!.oneRM, closeTo(142.5, 0.01));
    });

    group('weight max validation (kg)', () {
      Future<void> openAndSubmit(
        WidgetTester tester, {
        required String weight,
        required String reps,
      }) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<ExerciseRecord>(
                    MaterialPageRoute(
                      builder: (_) => const AddEntryScreen(
                        exerciseName: 'Test',
                        assetPath: 'assets/icons/back_squat.svg',
                        unit: WeightUnit.kg,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), weight);
        await tester.enterText(find.byType(TextFormField).at(1), reps);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      testWidgets('accepts exactly 1000 kg', (tester) async {
        ExerciseRecord? savedRecord;
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  savedRecord = await Navigator.of(context)
                      .push<ExerciseRecord>(
                        MaterialPageRoute(
                          builder: (_) => const AddEntryScreen(
                            exerciseName: 'Test',
                            assetPath: 'assets/icons/back_squat.svg',
                            unit: WeightUnit.kg,
                          ),
                        ),
                      );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), '1000');
        await tester.enterText(find.byType(TextFormField).at(1), '1');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(savedRecord, isNotNull);
        expect(savedRecord!.weight, 1000.0);
      });

      testWidgets('accepts 999.9 kg (just under max)', (tester) async {
        await openAndSubmit(tester, weight: '999.9', reps: '1');
        expect(find.text('Max 1,000 kg'), findsNothing);
      });

      testWidgets('rejects 1000.1 kg (just over max)', (tester) async {
        await openAndSubmit(tester, weight: '1000.1', reps: '1');
        expect(find.text('Max 1,000 kg'), findsOneWidget);
      });

      testWidgets('rejects 9999 kg (way over max)', (tester) async {
        await openAndSubmit(tester, weight: '9999', reps: '1');
        expect(find.text('Max 1,000 kg'), findsOneWidget);
      });

      testWidgets('rejects negative weight', (tester) async {
        await openAndSubmit(tester, weight: '-100', reps: '1');
        expect(find.text('Invalid'), findsOneWidget);
      });
    });

    group('reps max validation', () {
      Future<void> openAndSubmit(
        WidgetTester tester, {
        required String weight,
        required String reps,
      }) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<ExerciseRecord>(
                    MaterialPageRoute(
                      builder: (_) => const AddEntryScreen(
                        exerciseName: 'Test',
                        assetPath: 'assets/icons/back_squat.svg',
                        unit: WeightUnit.kg,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), weight);
        await tester.enterText(find.byType(TextFormField).at(1), reps);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      testWidgets('accepts exactly 50 reps', (tester) async {
        ExerciseRecord? savedRecord;
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  savedRecord = await Navigator.of(context)
                      .push<ExerciseRecord>(
                        MaterialPageRoute(
                          builder: (_) => const AddEntryScreen(
                            exerciseName: 'Test',
                            assetPath: 'assets/icons/back_squat.svg',
                            unit: WeightUnit.kg,
                          ),
                        ),
                      );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), '100');
        await tester.enterText(find.byType(TextFormField).at(1), '50');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(savedRecord, isNotNull);
        expect(savedRecord!.reps, 50);
      });

      testWidgets('accepts 1 rep (minimum valid)', (tester) async {
        await openAndSubmit(tester, weight: '100', reps: '1');
        expect(find.text('Invalid'), findsNothing);
        expect(find.text('Max 50 reps'), findsNothing);
      });

      testWidgets('rejects 51 reps (just over max)', (tester) async {
        await openAndSubmit(tester, weight: '100', reps: '51');
        expect(find.text('Max 50 reps'), findsOneWidget);
      });

      testWidgets('rejects 999 reps (way over max)', (tester) async {
        await openAndSubmit(tester, weight: '100', reps: '999');
        expect(find.text('Max 50 reps'), findsOneWidget);
      });

      testWidgets('rejects 0 reps', (tester) async {
        await openAndSubmit(tester, weight: '100', reps: '0');
        expect(find.text('Invalid'), findsOneWidget);
      });

      testWidgets('reps field only accepts digits (no sign or decimals)', (
        tester,
      ) async {
        await openAndSubmit(tester, weight: '100', reps: '-5.5');
        final reps = tester.widget<TextFormField>(
          find.byType(TextFormField).at(1),
        );
        expect(reps.controller!.text, '55');
        expect(find.text('Invalid'), findsNothing);
      });
    });

    testWidgets('shows both errors when weight and reps exceed max', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Test',
                      assetPath: 'assets/icons/back_squat.svg',
                      unit: WeightUnit.kg,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '5000');
      await tester.enterText(find.byType(TextFormField).at(1), '100');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Max 1,000 kg'), findsOneWidget);
      expect(find.text('Max 50 reps'), findsOneWidget);
    });
  });
  group('AddEntryScreen with lbs', () {
    testWidgets('shows lbs suffix when unit is lbs', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddEntryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            unit: WeightUnit.lbs,
          ),
        ),
      );

      expect(find.text('lbs'), findsOneWidget);
    });

    testWidgets('shows kg suffix when unit is kg', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddEntryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            unit: WeightUnit.kg,
          ),
        ),
      );

      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('converts lbs input to kg when calculating', (tester) async {
      ExerciseRecord? savedRecord;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Deadlift',
                      assetPath: 'assets/icons/deadlift.svg',
                      unit: WeightUnit.lbs,
                    ),
                  ),
                );
                savedRecord = result;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '225');
      await tester.enterText(find.byType(TextFormField).at(1), '5');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedRecord, isNotNull);
      expect(savedRecord!.weight, closeTo(102.058, 0.001));
      expect(savedRecord!.reps, 5);
      expect(savedRecord!.oneRM, closeTo(119.07, 0.01));
    });

    testWidgets('does not convert when unit is kg', (tester) async {
      ExerciseRecord? savedRecord;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Deadlift',
                      assetPath: 'assets/icons/deadlift.svg',
                      unit: WeightUnit.kg,
                    ),
                  ),
                );
                savedRecord = result;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '100');
      await tester.enterText(find.byType(TextFormField).at(1), '5');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedRecord, isNotNull);
      expect(savedRecord!.weight, 100.0);
      expect(savedRecord!.reps, 5);
      expect(savedRecord!.oneRM, closeTo(116.67, 0.01));
    });

    group('weight max validation (lbs)', () {
      Future<void> openAndSubmitLbs(
        WidgetTester tester, {
        required String weight,
        required String reps,
      }) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<ExerciseRecord>(
                    MaterialPageRoute(
                      builder: (_) => const AddEntryScreen(
                        exerciseName: 'Test',
                        assetPath: 'assets/icons/back_squat.svg',
                        unit: WeightUnit.lbs,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), weight);
        await tester.enterText(find.byType(TextFormField).at(1), reps);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      testWidgets('accepts 2204 lbs (just under max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '2204', reps: '1');
        expect(find.text('Max 2,205 lbs'), findsNothing);
      });

      testWidgets('accepts 2204.62 lbs (exactly at max)', (tester) async {
        ExerciseRecord? savedRecord;
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  savedRecord = await Navigator.of(context)
                      .push<ExerciseRecord>(
                        MaterialPageRoute(
                          builder: (_) => const AddEntryScreen(
                            exerciseName: 'Test',
                            assetPath: 'assets/icons/back_squat.svg',
                            unit: WeightUnit.lbs,
                          ),
                        ),
                      );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), '2204.62');
        await tester.enterText(find.byType(TextFormField).at(1), '1');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(savedRecord, isNotNull);
      });

      testWidgets('rejects 2205 lbs (just over max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '2205', reps: '1');
        expect(find.text('Max 2,205 lbs'), findsOneWidget);
      });

      testWidgets('rejects 9999 lbs (way over max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '9999', reps: '1');
        expect(find.text('Max 2,205 lbs'), findsOneWidget);
      });
    });

    testWidgets('rejects 51 reps in lbs mode', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => const AddEntryScreen(
                      exerciseName: 'Test',
                      assetPath: 'assets/icons/back_squat.svg',
                      unit: WeightUnit.lbs,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '225');
      await tester.enterText(find.byType(TextFormField).at(1), '51');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Max 50 reps'), findsOneWidget);
    });
  });

  group('AddEntryScreen — live estimate', () {
    Future<void> pump(WidgetTester tester, {WeightUnit unit = WeightUnit.kg}) =>
        tester.pumpWidget(
          buildTestApp(
            AddEntryScreen(
              exerciseName: 'Back Squat',
              assetPath: 'assets/icons/back_squat.svg',
              unit: unit,
            ),
          ),
        );

    String estimate(WidgetTester tester) =>
        tester.widget<Text>(find.byKey(const Key('estimate-value'))).data!;

    testWidgets('shows a dash until both fields are valid', (tester) async {
      await pump(tester);
      expect(estimate(tester), '—');

      await tester.enterText(find.byType(TextFormField).at(0), '100');
      await tester.pump();
      expect(estimate(tester), '—');

      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.pump();
      expect(estimate(tester), '116.7 kg');
    });

    testWidgets('goes back to a dash when input becomes invalid', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byType(TextFormField).at(0), '100');
      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), '0');
      await tester.pump();
      expect(estimate(tester), '—');

      await tester.enterText(find.byType(TextFormField).at(0), '1001');
      await tester.pump();
      expect(estimate(tester), '—');
    });

    testWidgets('shows the estimate in lbs', (tester) async {
      await pump(tester, unit: WeightUnit.lbs);
      await tester.enterText(find.byType(TextFormField).at(0), '225');
      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.pump();

      expect(estimate(tester), '225.0 lbs');
    });

    testWidgets('warns about accuracy only above 10 reps', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextFormField).at(0), '60');

      await tester.enterText(find.byType(TextFormField).at(1), '10');
      await tester.pump();
      expect(find.byKey(const Key('high-reps-warning')), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(1), '11');
      await tester.pump();
      expect(find.byKey(const Key('high-reps-warning')), findsOneWidget);
    });

    testWidgets('weight "next" moves focus to reps', (tester) async {
      await pump(tester);
      await tester.showKeyboard(find.byType(TextFormField).at(0));
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      final reps = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
      expect(reps.focusNode.hasFocus, isTrue);
    });

    testWidgets('save button is always visible at the bottom', (tester) async {
      await pump(tester);
      final button = find.byKey(const Key('save-entry-button'));
      expect(button, findsOneWidget);
      expect(
        tester.getBottomLeft(button).dy,
        greaterThan(
          tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.8,
        ),
      );
    });
  });

  group('AddEntryScreen — date', () {
    final now = DateTime(2026, 9, 23, 10, 30);

    Future<ExerciseRecord?> openForm(
      WidgetTester tester, {
      ExerciseRecord? initial,
      WeightUnit unit = WeightUnit.kg,
      required Future<void> Function() interact,
    }) async {
      ExerciseRecord? result;
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(
                      exerciseName: 'Deadlift',
                      assetPath: 'assets/icons/deadlift.svg',
                      unit: unit,
                      initial: initial,
                      clock: () => now,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await interact();
      return result;
    }

    Future<void> fillAndSave(WidgetTester tester) async {
      await tester.enterText(find.byType(TextFormField).at(0), '180');
      await tester.enterText(find.byType(TextFormField).at(1), '3');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    testWidgets('defaults to today and saves with the current time', (
      tester,
    ) async {
      final record = await openForm(
        tester,
        interact: () async {
          expect(find.text('Today'), findsOneWidget);
          await fillAndSave(tester);
        },
      );

      expect(record!.date, now);
    });

    testWidgets('a past day can be picked and keeps the time of day', (
      tester,
    ) async {
      final record = await openForm(
        tester,
        interact: () async {
          await tester.tap(find.byKey(const Key('entry-date-field')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('20'));
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          expect(find.text('3 days ago'), findsOneWidget);
          await fillAndSave(tester);
        },
      );

      expect(record!.date, DateTime(2026, 9, 20, 10, 30));
    });

    testWidgets('future days cannot be picked', (tester) async {
      final record = await openForm(
        tester,
        interact: () async {
          await tester.tap(find.byKey(const Key('entry-date-field')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('25'));
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          expect(find.text('Today'), findsOneWidget);
          await fillAndSave(tester);
        },
      );

      expect(record!.date, now);
    });

    testWidgets('cancelling the picker keeps the date', (tester) async {
      final record = await openForm(
        tester,
        interact: () async {
          await tester.tap(find.byKey(const Key('entry-date-field')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('20'));
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          await fillAndSave(tester);
        },
      );

      expect(record!.date, now);
    });
  });

  group('AddEntryScreen — editing', () {
    final original = ExerciseRecord(
      weight: 100,
      reps: 5,
      oneRM: 116.67,
      date: DateTime(2026, 9, 1, 18),
    );

    testWidgets('prefills the fields and keeps the original date', (
      tester,
    ) async {
      ExerciseRecord? result;
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<ExerciseRecord>(
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(
                      exerciseName: 'Back Squat',
                      assetPath: 'assets/icons/back_squat.svg',
                      unit: WeightUnit.kg,
                      initial: original,
                      clock: () => DateTime(2026, 9, 23),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('EDIT ENTRY'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(_fieldText(tester, 0), '100');
      expect(_fieldText(tester, 1), '5');
      expect(find.text('116.7 kg'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), '6');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(result!.weight, 100);
      expect(result!.reps, 6);
      expect(result!.oneRM, closeTo(120, 0.001));
      expect(result!.date, original.date);
    });

    testWidgets('prefills lbs without trailing zeros', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          AddEntryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            unit: WeightUnit.lbs,
            initial: ExerciseRecord(
              weight: lbsToKg(225),
              reps: 1,
              oneRM: lbsToKg(225),
              date: DateTime(2026),
            ),
          ),
        ),
      );

      expect(_fieldText(tester, 0), '225');
    });
  });
  group('AddEntryScreen in Spanish', () {
    Future<void> pump(WidgetTester tester, WeightUnit unit) async {
      await tester.pumpWidget(
        buildTestApp(
          AddEntryScreen(
            exerciseName: 'Peso muerto',
            assetPath: 'assets/icons/deadlift.svg',
            unit: unit,
            clock: () => DateTime(2026, 9, 23, 10),
          ),
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('labels, hint with a decimal comma and relative date', (
      tester,
    ) async {
      await pump(tester, WeightUnit.kg);

      expect(find.text('INTRODUCE TU SERIE'), findsOneWidget);
      expect(find.text('Peso'), findsOneWidget);
      expect(find.text('112,5'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('1RM ESTIMADO'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('a decimal comma is accepted and the estimate uses one', (
      tester,
    ) async {
      await pump(tester, WeightUnit.kg);

      await tester.enterText(find.byType(TextFormField).at(0), '112,5');
      await tester.enterText(find.byType(TextFormField).at(1), '3');
      await tester.pump();

      expect(find.text('123,8 kg'), findsOneWidget);
    });

    testWidgets('validation messages', (tester) async {
      await pump(tester, WeightUnit.lbs);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Obligatorio'), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).at(0), '9999');
      await tester.enterText(find.byType(TextFormField).at(1), '51');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Máx. 2.205 lbs'), findsOneWidget);
      expect(find.text('Máx. 50 reps'), findsOneWidget);
    });

    testWidgets('warns about high reps', (tester) async {
      await pump(tester, WeightUnit.kg);

      await tester.enterText(find.byType(TextFormField).at(1), '12');
      await tester.pump();

      expect(
        find.text('Las estimaciones son menos precisas por encima de 10 reps.'),
        findsOneWidget,
      );
    });
  });
}

String _fieldText(WidgetTester tester, int index) => tester
    .widget<TextFormField>(find.byType(TextFormField).at(index))
    .controller!
    .text;
