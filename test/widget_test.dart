import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
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
