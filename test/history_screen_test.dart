import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(theme: AppTheme.dark, home: home);
}

void main() {
  group('HistoryScreen', () {
    testWidgets('displays weight in kg when unit is kg', (tester) async {
      final records = [
        ExerciseRecord(
          weight: 100.0,
          reps: 5,
          oneRM: 116.7,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          HistoryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            records: records,
            unit: WeightUnit.kg,
          ),
        ),
      );

      expect(find.textContaining('kg'), findsWidgets);
      expect(find.textContaining('100.0 kg'), findsOneWidget);
    });

    testWidgets('displays weight in lbs when unit is lbs', (tester) async {
      final records = [
        ExerciseRecord(
          weight: 100.0,
          reps: 5,
          oneRM: 116.7,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          HistoryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            records: records,
            unit: WeightUnit.lbs,
          ),
        ),
      );

      expect(find.textContaining('lbs'), findsWidgets);
      expect(find.textContaining('220.5 lbs'), findsOneWidget);
    });

    testWidgets('displays 1RM in correct unit', (tester) async {
      final records = [
        ExerciseRecord(
          weight: 100.0,
          reps: 5,
          oneRM: 116.7,
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          HistoryScreen(
            exerciseName: 'Back Squat',
            assetPath: 'assets/icons/back_squat.svg',
            records: records,
            unit: WeightUnit.lbs,
          ),
        ),
      );

      expect(find.textContaining('1RM: 257.3 lbs'), findsOneWidget);
    });
  });
}
