import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';

import '../helpers/test_app.dart';

void main() {
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
          id: 'super_long_name_exercise',
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
          buildTestApp(
            ExerciseDetailScreen(
              template: dummyExercise,
              records: RecordsRepository(StorageService.inMemoryForTesting(), {
                dummyExercise.id: [massiveRecord],
              }),
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
}
