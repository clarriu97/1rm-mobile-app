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
  });
}
