import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

final _squat = defaultExercises.first;

ExerciseRecord _record({double weight = 100, int reps = 5}) => ExerciseRecord(
  weight: weight,
  reps: reps,
  oneRM: calculateOneRM(weight, reps),
  date: DateTime(2026, 9, 20),
);

Widget _app(Widget home, {TargetPlatform? platform}) => MaterialApp(
  theme: AppTheme.dark.copyWith(platform: platform),
  home: home,
);

Future<void> _logEntry(WidgetTester tester, String weight, String reps) async {
  await tester.tap(find.text('Add Entry'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), weight);
  await tester.enterText(find.byType(TextFormField).at(1), reps);
  await tester.tap(find.text('Calculate 1RM'));
  await tester.pumpAndSettle();
}

void main() {
  group('ExerciseDetailScreen persistence', () {
    testWidgets('entry is saved without leaving the detail screen', (
      tester,
    ) async {
      final storage = StorageService.inMemoryForTesting();
      final records = RecordsRepository(storage);

      await tester.pumpWidget(
        _app(
          ExerciseDetailScreen(
            template: _squat,
            records: records,
            unit: WeightUnit.kg,
          ),
        ),
      );
      await _logEntry(tester, '100', '5');

      // Still on the detail screen: the app could be killed right now.
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      expect(find.text('116.7 kg'), findsWidgets);

      final saved = (await storage.load())[_squat.id];
      expect(saved, hasLength(1));
      expect(saved!.single.weight, 100);
      expect(saved.single.reps, 5);
    });

    testWidgets('cancelling the add form saves nothing', (tester) async {
      final storage = StorageService.inMemoryForTesting();

      await tester.pumpWidget(
        _app(
          ExerciseDetailScreen(
            template: _squat,
            records: RecordsRepository(storage),
            unit: WeightUnit.kg,
          ),
        ),
      );
      await tester.tap(find.text('Add Entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No records yet'), findsOneWidget);
      expect(await storage.load(), isEmpty);
    });

    testWidgets('iOS swipe-back gesture pops the detail screen', (
      tester,
    ) async {
      final records = RecordsRepository(StorageService.inMemoryForTesting(), {
        _squat.id: [_record()],
      });

      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ExerciseDetailScreen(
                    template: _squat,
                    records: records,
                    unit: WeightUnit.kg,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);

      await tester.dragFrom(const Offset(5, 300), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseDetailScreen), findsNothing);
    });
  });

  group('HistoryScreen persistence', () {
    testWidgets('confirmed delete is saved immediately', (tester) async {
      final storage = StorageService.inMemoryForTesting();
      final records = RecordsRepository(storage, {
        _squat.id: [_record()],
      });
      await storage.save({
        _squat.id: [_record()],
      });

      await tester.pumpWidget(
        _app(
          HistoryScreen(
            template: _squat,
            records: records,
            unit: WeightUnit.kg,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('No records yet'), findsOneWidget);
      expect(await storage.load(), isEmpty);
    });

    testWidgets('cancelled delete keeps the entry', (tester) async {
      final storage = StorageService.inMemoryForTesting();
      final records = RecordsRepository(storage, {
        _squat.id: [_record()],
      });

      await tester.pumpWidget(
        _app(
          HistoryScreen(
            template: _squat,
            records: records,
            unit: WeightUnit.kg,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('No records yet'), findsNothing);
      expect(records.recordsFor(_squat.id), hasLength(1));
    });
  });

  group('HomeScreen', () {
    testWidgets('shows best 1RM logged from the detail screen after back', (
      tester,
    ) async {
      final records = RecordsRepository(StorageService.inMemoryForTesting());

      await tester.pumpWidget(
        _app(
          HomeScreen(records: records, unitService: UnitService.forTesting()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('116.7 kg'), findsNothing);

      await tester.tap(find.text(_squat.name));
      await tester.pumpAndSettle();
      await _logEntry(tester, '100', '5');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('116.7 kg'), findsOneWidget);
    });

    testWidgets('rebuilds when the repository changes', (tester) async {
      final records = RecordsRepository(StorageService.inMemoryForTesting());

      await tester.pumpWidget(
        _app(
          HomeScreen(records: records, unitService: UnitService.forTesting()),
        ),
      );
      await tester.pumpAndSettle();

      await records.add(_squat.id, _record(weight: 200, reps: 1));
      await tester.pump();

      expect(find.text('200.0 kg'), findsOneWidget);
    });
  });
}
