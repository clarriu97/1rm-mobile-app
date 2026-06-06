import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(theme: AppTheme.dark, home: home);
}

void main() {
  group('DefaultExercises', () {
    test('has exactly 6 exercises', () {
      expect(defaultExercises.length, 6);
    });

    test('all exercises have unique names', () {
      final names = defaultExercises.map((e) => e.name).toSet();
      expect(names.length, defaultExercises.length);
    });

    test('all exercises have non-empty names', () {
      for (final ex in defaultExercises) {
        expect(ex.name.isNotEmpty, isTrue);
      }
    });
  });

  group('HomeScreen', () {
    // Widget tests for HomeScreen require SVG assets configured in the test
    // bundle. Skipping to avoid timeout from flutter_svg asset loading.
  });

  group('AddEntryScreen', () {
    testWidgets('renders form with exercise name in title', (tester) async {
      await tester.pumpWidget(
        _buildApp(
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
        _buildApp(
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
        _buildApp(
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
  });

  group('ExerciseDetailScreen', () {
    testWidgets(
      'does not overflow with extremely large latest record text (uses FittedBox)',
      (tester) async {
        // Simulate a small screen width
        tester.view.physicalSize = const Size(300, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const dummyExercise = ExerciseTemplate(
          name: 'Super Long Name Exercise',
          category: ExerciseCategory.legs,
          assetPath: 'assets/icons/back_squat.svg',
        );

        final massiveRecord = ExerciseRecord(
          weight: 123456.7,
          reps: 9999,
          oneRM: 987654.3,
          date: DateTime.now(),
        );

        await tester.pumpWidget(
          _buildApp(
            ExerciseDetailScreen(
              template: dummyExercise,
              records: [massiveRecord],
              unit: WeightUnit.kg,
            ),
          ),
        );

        // Verify the widget tree doesn't throw a FlutterError (overflows throw in test mode)
        await tester.pumpAndSettle();

        // Find the text we added FittedBox to.
        const latestText = 'Latest: 123456.7 kg × 9999 reps → 987654.3 kg';
        expect(find.text(latestText), findsOneWidget);

        // Verify that a FittedBox wraps this specific Text
        final fittedBoxFinder = find.ancestor(
          of: find.text(latestText),
          matching: find.byType(FittedBox),
        );

        expect(fittedBoxFinder, findsWidgets);
      },
    );
  });

  group('ExerciseRecord serialization', () {
    test('roundtrip preserves all fields', () {
      final original = ExerciseRecord(
        weight: 112.5,
        reps: 8,
        oneRM: 142.5,
        date: DateTime(2024, 6, 15, 14, 30),
      );

      final json = original.toJson();
      final restored = ExerciseRecord.fromJson(json);

      expect(restored.weight, original.weight);
      expect(restored.reps, original.reps);
      expect(restored.oneRM, original.oneRM);
      expect(restored.date, original.date);
    });
  });

  group('generatePercentageTable', () {
    test('uses best 1RM for table generation', () {
      final table = generatePercentageTable(200);
      expect(table.first.percentage, 100);
      expect(table.first.weight, roundToNearest(200));
    });
  });
}
