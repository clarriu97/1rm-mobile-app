import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(theme: AppTheme.dark, home: home);
}

void main() {
  group('AddEntryScreen with lbs', () {
    testWidgets('shows lbs suffix when unit is lbs', (tester) async {
      await tester.pumpWidget(
        _buildApp(
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
        _buildApp(
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
        _buildApp(
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
        _buildApp(
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
          _buildApp(
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
          _buildApp(
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
        _buildApp(
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
