import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

void main() {
  group('DefaultExercises', () {
    test('has exactly 12 exercises', () {
      expect(defaultExercises.length, 12);
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

    test('each exercise has a unique icon', () {
      final icons = defaultExercises.map((e) => e.icon).toSet();
      expect(icons.length, defaultExercises.length);
    });
  });

  group('HomeScreen', () {
    testWidgets('renders exercise grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      );

      expect(find.text('1RM'), findsOneWidget);
      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    });
  });

  group('AddEntryScreen', () {
    testWidgets('renders form with exercise name in title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AddEntryScreen(
            exerciseName: 'Back Squat',
            icon: Icons.fitness_center_rounded,
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
        MaterialApp(
          theme: AppTheme.dark,
          home: const AddEntryScreen(
            exerciseName: 'Test',
            icon: Icons.fitness_center_rounded,
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
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context)
                      .push<ExerciseRecord>(
                        MaterialPageRoute(
                          builder: (_) => const AddEntryScreen(
                            exerciseName: 'Deadlift',
                            icon: Icons.arrow_circle_up_rounded,
                          ),
                        ),
                      );
                  savedRecord = result;
                },
                child: const Text('Open'),
              );
            },
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
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context)
                      .push<ExerciseRecord>(
                        MaterialPageRoute(
                          builder: (_) => const AddEntryScreen(
                            exerciseName: 'Bench Press',
                            icon: Icons.horizontal_distribute_rounded,
                          ),
                        ),
                      );
                  savedRecord = result;
                },
                child: const Text('Open'),
              );
            },
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

  group('generatePercentageTable', () {
    test('uses best 1RM for table generation', () {
      final table = generatePercentageTable(200);
      expect(table.first.percentage, 100);
      expect(table.first.weight, roundToNearest(200));
    });
  });
}
