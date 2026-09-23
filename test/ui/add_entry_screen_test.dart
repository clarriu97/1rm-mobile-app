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
      expect(find.text('Calculate 1RM'), findsOneWidget);
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

      await tester.tap(find.text('Calculate 1RM'));
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

      await tester.tap(find.text('Calculate 1RM'));
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

      await tester.tap(find.text('Calculate 1RM'));
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
        await tester.tap(find.text('Calculate 1RM'));
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
        await tester.tap(find.text('Calculate 1RM'));
        await tester.pumpAndSettle();
        expect(savedRecord, isNotNull);
        expect(savedRecord!.weight, 1000.0);
      });

      testWidgets('accepts 999.9 kg (just under max)', (tester) async {
        await openAndSubmit(tester, weight: '999.9', reps: '1');
        expect(find.text('Max 1000 kg'), findsNothing);
      });

      testWidgets('rejects 1000.1 kg (just over max)', (tester) async {
        await openAndSubmit(tester, weight: '1000.1', reps: '1');
        expect(find.text('Max 1000 kg'), findsOneWidget);
      });

      testWidgets('rejects 9999 kg (way over max)', (tester) async {
        await openAndSubmit(tester, weight: '9999', reps: '1');
        expect(find.text('Max 1000 kg'), findsOneWidget);
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
        await tester.tap(find.text('Calculate 1RM'));
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
        await tester.tap(find.text('Calculate 1RM'));
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

      testWidgets('rejects negative reps', (tester) async {
        await openAndSubmit(tester, weight: '100', reps: '-5');
        expect(find.text('Invalid'), findsOneWidget);
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
      await tester.tap(find.text('Calculate 1RM'));
      await tester.pumpAndSettle();
      expect(find.text('Max 1000 kg'), findsOneWidget);
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

      await tester.tap(find.text('Calculate 1RM'));
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

      await tester.tap(find.text('Calculate 1RM'));
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
        await tester.tap(find.text('Calculate 1RM'));
        await tester.pumpAndSettle();
      }

      testWidgets('accepts 2204 lbs (just under max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '2204', reps: '1');
        expect(find.text('Max 2205 lbs'), findsNothing);
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
        await tester.tap(find.text('Calculate 1RM'));
        await tester.pumpAndSettle();
        expect(savedRecord, isNotNull);
      });

      testWidgets('rejects 2205 lbs (just over max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '2205', reps: '1');
        expect(find.text('Max 2205 lbs'), findsOneWidget);
      });

      testWidgets('rejects 9999 lbs (way over max)', (tester) async {
        await openAndSubmitLbs(tester, weight: '9999', reps: '1');
        expect(find.text('Max 2205 lbs'), findsOneWidget);
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
      await tester.tap(find.text('Calculate 1RM'));
      await tester.pumpAndSettle();
      expect(find.text('Max 50 reps'), findsOneWidget);
    });
  });
}
