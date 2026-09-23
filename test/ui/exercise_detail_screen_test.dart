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

  group('ExerciseDetailScreen — working weights table', () {
    Future<void> pump(WidgetTester tester, double oneRMKg, WeightUnit unit) =>
        tester.pumpWidget(
          buildTestApp(
            ExerciseDetailScreen(
              template: defaultExercises.first,
              records: RecordsRepository(StorageService.inMemoryForTesting(), {
                defaultExercises.first.id: [
                  ExerciseRecord(
                    weight: oneRMKg,
                    reps: 1,
                    oneRM: oneRMKg,
                    date: DateTime(2026, 9, 20),
                  ),
                ],
              }),
              unit: unit,
            ),
          ),
        );

    Future<void> showTable(WidgetTester tester) => tester.scrollUntilVisible(
      find.byKey(const Key('working-weights-table')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    List<String> tableWeights(WidgetTester tester) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('working-weights-table')),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data!)
        .where((s) => s.endsWith(' kg') || s.endsWith(' lbs'))
        .toList();

    testWidgets('lbs working weights are loadable multiples of 5 lbs', (
      tester,
    ) async {
      await pump(tester, 100, WeightUnit.lbs); // 100 kg = 220.46 lbs
      await showTable(tester);

      final weights = tableWeights(tester);
      expect(weights, isNotEmpty);
      for (final w in weights) {
        final value = double.parse(w.split(' ').first);
        expect(value % 5, 0, reason: w);
      }
      expect(weights.first, '220 lbs');
    });

    testWidgets('kg working weights are whole kilos without decimals', (
      tester,
    ) async {
      await pump(tester, 116.7, WeightUnit.kg);
      await showTable(tester);

      final weights = tableWeights(tester);
      expect(weights.first, '117 kg');
      expect(find.text('Rounded to the nearest 1 kg.'), findsOneWidget);
    });

    testWidgets('reps mode lists 1 to 10 reps from the 1RM down', (
      tester,
    ) async {
      await pump(tester, 150, WeightUnit.kg);
      await showTable(tester);
      await tester.ensureVisible(find.byKey(const Key('table-REPS')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('table-REPS')));
      await tester.pumpAndSettle();

      expect(find.text('REPS'), findsWidgets);
      expect(find.text('1 rep'), findsOneWidget);
      expect(find.text('10 reps'), findsOneWidget);
      final weights = tableWeights(tester);
      expect(weights.first, '150 kg');
      expect(weights.last, '113 kg'); // 150 / (1 + 10/30) = 112.5 → 113
      expect(weights, hasLength(10));
    });

    testWidgets('switching back to % restores the percentage rows', (
      tester,
    ) async {
      await pump(tester, 150, WeightUnit.kg);
      await showTable(tester);
      await tester.ensureVisible(find.byKey(const Key('table-REPS')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('table-REPS')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('table-%')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('table-%')));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(tableWeights(tester), hasLength(11));
    });

    testWidgets('add button lives in the bottom bar, not over the table', (
      tester,
    ) async {
      await pump(tester, 150, WeightUnit.kg);

      expect(find.byType(FloatingActionButton), findsNothing);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(
        find.descendant(
          of: find.byWidget(scaffold.bottomNavigationBar!),
          matching: find.text('Add Entry'),
        ),
        findsOneWidget,
      );
    });
  });
}
