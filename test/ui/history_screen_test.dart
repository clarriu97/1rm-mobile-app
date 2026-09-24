import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';

import '../helpers/test_app.dart';

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
        buildTestApp(
          HistoryScreen(
            template: defaultExercises.first,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              defaultExercises.first.id: records,
            }),
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
        buildTestApp(
          HistoryScreen(
            template: defaultExercises.first,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              defaultExercises.first.id: records,
            }),
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
        buildTestApp(
          HistoryScreen(
            template: defaultExercises.first,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              defaultExercises.first.id: records,
            }),
            unit: WeightUnit.lbs,
          ),
        ),
      );

      expect(find.textContaining('1RM: 257.3 lbs'), findsOneWidget);
    });
  });

  group('HistoryScreen — grouping, editing, swiping', () {
    final now = DateTime(2026, 9, 23, 18);

    ExerciseRecord record(double weight, DateTime date) =>
        ExerciseRecord(weight: weight, reps: 1, oneRM: weight, date: date);

    Future<RecordsRepository> pump(
      WidgetTester tester,
      List<ExerciseRecord> entries,
    ) async {
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        defaultExercises.first.id: entries,
      });
      await tester.pumpWidget(
        buildTestApp(
          HistoryScreen(
            template: defaultExercises.first,
            records: repo,
            unit: WeightUnit.kg,
            clock: () => now,
          ),
        ),
      );
      return repo;
    }

    testWidgets('groups entries under month headers, newest first', (
      tester,
    ) async {
      await pump(tester, [
        record(100, DateTime(2026, 8, 10)),
        record(110, DateTime(2026, 9, 21)),
        record(105, DateTime(2026, 9, 5)),
      ]);

      final sep = tester.getTopLeft(find.text('SEPTEMBER 2026')).dy;
      final aug = tester.getTopLeft(find.text('AUGUST 2026')).dy;
      expect(sep, lessThan(aug));
      expect(
        tester.getTopLeft(find.text('110.0 kg × 1 rep')).dy,
        lessThan(tester.getTopLeft(find.text('105.0 kg × 1 rep')).dy),
      );
      expect(
        tester.getTopLeft(find.text('105.0 kg × 1 rep')).dy,
        lessThan(aug),
      );
    });

    testWidgets('recent entries use relative dates, older ones month + day', (
      tester,
    ) async {
      await pump(tester, [
        record(110, DateTime(2026, 9, 21)),
        record(100, DateTime(2026, 8, 10)),
      ]);

      expect(find.text('2 days ago'), findsOneWidget);
      expect(find.text('Aug 10'), findsOneWidget);
    });

    testWidgets('tapping an entry opens the editor and saves the change', (
      tester,
    ) async {
      final original = record(100, DateTime(2026, 9, 20));
      final repo = await pump(tester, [original]);

      await tester.tap(find.text('100.0 kg × 1 rep'));
      await tester.pumpAndSettle();
      expect(find.text('EDIT ENTRY'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '102.5');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      final updated = repo.recordsFor(defaultExercises.first.id).single;
      expect(updated.weight, 102.5);
      expect(updated.date, original.date);
      expect(find.text('102.5 kg × 1 rep'), findsOneWidget);
    });

    testWidgets('closing the editor leaves the entry untouched', (
      tester,
    ) async {
      final original = record(100, DateTime(2026, 9, 20));
      final repo = await pump(tester, [original]);

      await tester.tap(find.text('100.0 kg × 1 rep'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(repo.recordsFor(defaultExercises.first.id).single, same(original));
    });

    testWidgets('swiping left deletes with undo', (tester) async {
      final original = record(100, DateTime(2026, 9, 20));
      final repo = await pump(tester, [original]);

      await tester.drag(find.text('100.0 kg × 1 rep'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(repo.recordsFor(defaultExercises.first.id), isEmpty);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.recordsFor(defaultExercises.first.id).single, same(original));
    });

    testWidgets('swiping right does nothing', (tester) async {
      final repo = await pump(tester, [record(100, DateTime(2026, 9, 20))]);

      await tester.drag(find.text('100.0 kg × 1 rep'), const Offset(600, 0));
      await tester.pumpAndSettle();

      expect(repo.recordsFor(defaultExercises.first.id), hasLength(1));
    });
  });
  group('HistoryScreen in Spanish', () {
    final now = DateTime(2026, 9, 23, 10);

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HistoryScreen(
            template: defaultExercises.first,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              defaultExercises.first.id: [
                ExerciseRecord(
                  weight: 100,
                  reps: 1,
                  oneRM: 100,
                  date: DateTime(2026, 9, 21),
                ),
                ExerciseRecord(
                  weight: 102.5,
                  reps: 3,
                  oneRM: 112.75,
                  date: DateTime(2026, 8, 10),
                ),
              ],
            }),
            unit: WeightUnit.kg,
            clock: () => now,
          ),
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('title, sets, months and dates', (tester) async {
      await pump(tester);

      expect(find.text('Historial de Sentadilla trasera'), findsOneWidget);
      expect(find.text('100,0 kg × 1 rep'), findsOneWidget);
      expect(find.text('102,5 kg × 3 reps'), findsOneWidget);
      expect(find.text('1RM: 112,8 kg'), findsOneWidget);
      expect(find.text('SEPTIEMBRE DE 2026'), findsOneWidget);
      expect(find.text('Hace 2 días'), findsOneWidget);
      expect(find.byTooltip('Eliminar'), findsNWidgets(2));
    });

    testWidgets('deleting offers Deshacer', (tester) async {
      await pump(tester);

      await tester.tap(find.byTooltip('Eliminar').first);
      await tester.pumpAndSettle();

      expect(find.text('Borrado: 100,0 kg × 1 rep'), findsOneWidget);
      expect(find.text('Deshacer'), findsOneWidget);
    });
  });
}
