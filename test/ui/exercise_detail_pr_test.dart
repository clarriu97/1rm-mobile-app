import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';
import 'package:one_rm_mobile/ui/widgets/pr_celebration.dart';

import '../helpers/test_app.dart';

final _squat = defaultExercises.first;

ExerciseRecord _record(double oneRM, DateTime date) =>
    ExerciseRecord(weight: oneRM, reps: 1, oneRM: oneRM, date: date);

Future<void> _log(WidgetTester tester, String weight) async {
  await tester.tap(find.text('Add Entry'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), weight);
  await tester.enterText(find.byType(TextFormField).at(1), '1');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Future<void> _pumpDetail(WidgetTester tester, RecordsRepository records) =>
    tester.pumpWidget(
      buildTestApp(
        ExerciseDetailScreen(
          template: _squat,
          records: records,
          unit: WeightUnit.kg,
        ),
      ),
    );

void main() {
  group('ExerciseDetailScreen — PR celebration', () {
    testWidgets('first entry is not celebrated', (tester) async {
      await _pumpDetail(
        tester,
        RecordsRepository(StorageService.inMemoryForTesting()),
      );
      await _log(tester, '150');

      expect(find.text('NEW PR'), findsNothing);
    });

    testWidgets('beating the best is celebrated with the gain', (tester) async {
      await _pumpDetail(
        tester,
        RecordsRepository(StorageService.inMemoryForTesting(), {
          _squat.id: [_record(150, DateTime(2026, 9, 2))],
        }),
      );
      await _log(tester, '155');

      expect(find.text('NEW PR'), findsOneWidget);
      expect(find.text('+5.0 kg over your previous best'), findsOneWidget);

      await tester.pump(kPrCelebrationDuration);
      await tester.pumpAndSettle();
      expect(find.text('NEW PR'), findsNothing);
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
    });

    testWidgets('matching or missing the best is not celebrated', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        RecordsRepository(StorageService.inMemoryForTesting(), {
          _squat.id: [_record(150, DateTime(2026, 9, 2))],
        }),
      );
      await _log(tester, '150');
      expect(find.text('NEW PR'), findsNothing);

      await _log(tester, '140');
      expect(find.text('NEW PR'), findsNothing);
    });
  });

  group('HistoryScreen — PR badges', () {
    testWidgets('marks entries that beat the previous best', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HistoryScreen(
            template: _squat,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              _squat.id: [
                _record(100, DateTime(2026, 9, 2)),
                _record(110, DateTime(2026, 9, 8)),
                _record(105, DateTime(2026, 9, 15)),
                _record(115, DateTime(2026, 9, 22)),
              ],
            }),
            unit: WeightUnit.kg,
          ),
        ),
      );

      expect(find.byKey(const Key('pr-badge')), findsNWidgets(2));
      for (final weight in ['110.0 kg × 1 reps', '115.0 kg × 1 reps']) {
        expect(
          find.descendant(
            of: find.ancestor(
              of: find.text(weight),
              matching: find.byType(Row),
            ),
            matching: find.byKey(const Key('pr-badge')),
          ),
          findsWidgets,
          reason: weight,
        );
      }
    });

    testWidgets('no badges with a single entry', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HistoryScreen(
            template: _squat,
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              _squat.id: [_record(100, DateTime(2026, 9, 2))],
            }),
            unit: WeightUnit.kg,
          ),
        ),
      );

      expect(find.byKey(const Key('pr-badge')), findsNothing);
    });
  });
}
