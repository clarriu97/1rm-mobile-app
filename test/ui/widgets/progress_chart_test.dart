import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/widgets/progress_chart.dart';

import '../../helpers/test_app.dart';

final _now = DateTime(2026, 9, 23, 12);

ExerciseRecord _record(double oneRM, DateTime date) =>
    ExerciseRecord(weight: oneRM, reps: 1, oneRM: oneRM, date: date);

void main() {
  group('ProgressRange.startFrom', () {
    test('3M and 1Y go back by calendar months and years', () {
      expect(ProgressRange.threeMonths.startFrom(_now), DateTime(2026, 6, 23));
      expect(ProgressRange.year.startFrom(_now), DateTime(2025, 9, 23));
      expect(ProgressRange.all.startFrom(_now), isNull);
    });

    test('3M crosses into the previous year', () {
      expect(
        ProgressRange.threeMonths.startFrom(DateTime(2026, 2, 10)),
        DateTime(2025, 11, 10),
      );
    });
  });

  group('recordsInRange', () {
    final old = _record(100, DateTime(2025, 1, 10));
    final boundary = _record(110, DateTime(2026, 6, 23));
    final recent = _record(120, DateTime(2026, 9, 20));

    test('keeps records on or after the start, oldest first', () {
      expect(
        recordsInRange(
          [recent, old, boundary],
          ProgressRange.threeMonths,
          _now,
        ),
        [boundary, recent],
      );
    });

    test('ALL keeps everything sorted', () {
      expect(recordsInRange([recent, old, boundary], ProgressRange.all, _now), [
        old,
        boundary,
        recent,
      ]);
    });

    test('empty input gives empty output', () {
      expect(recordsInRange([], ProgressRange.year, _now), isEmpty);
    });
  });

  group('progressSpots', () {
    test('x is days since the first record, fractional by time of day', () {
      final spots = progressSpots([
        _record(100, DateTime(2026, 9, 2)),
        _record(110, DateTime(2026, 9, 4, 12)),
      ], WeightUnit.kg);

      expect(spots.map((s) => s.x), [0, 2.5]);
      expect(spots.map((s) => s.y), [100, 110]);
    });

    test('y is converted to lbs', () {
      final spots = progressSpots([
        _record(100, DateTime(2026, 9, 2)),
      ], WeightUnit.lbs);
      expect(spots.single.y, closeTo(220.46, 0.01));
    });

    test('empty input gives no spots', () {
      expect(progressSpots([], WeightUnit.kg), isEmpty);
    });
  });

  group('niceStep', () {
    test('picks 1, 2, 2.5 or 5 times a power of ten', () {
      expect(niceStep(3), 1);
      expect(niceStep(6), 2);
      expect(niceStep(7.5), 2.5);
      expect(niceStep(12), 5);
      expect(niceStep(40), 20);
      expect(niceStep(60), 20);
      expect(niceStep(70), 25);
      expect(niceStep(130), 50);
      expect(niceStep(0.9), 0.5);
    });

    test('non-positive range falls back to 1', () {
      expect(niceStep(0), 1);
      expect(niceStep(-5), 1);
    });
  });

  group('progressYBounds', () {
    void expectSnapped(({double min, double max, double step}) b) {
      expect(b.min % b.step, closeTo(0, 1e-9));
      expect(b.max % b.step, closeTo(0, 1e-9));
    }

    test('contains the data with padding and snaps to the step', () {
      final b = progressYBounds(const [FlSpot(0, 140), FlSpot(1, 170)]);
      expect(b.min, lessThan(140));
      expect(b.max, greaterThan(170));
      expectSnapped(b);
      expect((b.max - b.min) / b.step, inInclusiveRange(2, 6));
    });

    test('flat series still gets a visible band', () {
      final b = progressYBounds(const [FlSpot(0, 100), FlSpot(1, 100)]);
      expect(b.min, lessThan(100));
      expect(b.max, greaterThan(100));
      expectSnapped(b);
    });

    test('never goes below zero', () {
      final b = progressYBounds(const [FlSpot(0, 1), FlSpot(1, 2)]);
      expect(b.min, 0);
    });

    test('works in lbs magnitudes', () {
      final b = progressYBounds(const [FlSpot(0, 315), FlSpot(1, 405)]);
      expectSnapped(b);
      expect(b.step, 50);
    });
  });

  group('ProgressChart widget', () {
    Future<void> pump(
      WidgetTester tester,
      List<ExerciseRecord> records, {
      Set<ExerciseRecord>? prs,
      bool reduceMotion = false,
    }) => tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: ProgressChart(
                records: records,
                personalRecords: prs ?? Set.identity(),
                unit: WeightUnit.kg,
                now: _now,
              ),
            ),
          ),
        ),
      ),
    );

    LineChart chart(WidgetTester tester) =>
        tester.widget<LineChart>(find.byKey(const Key('progress-line-chart')));

    testWidgets('asks for more data with fewer than two records', (
      tester,
    ) async {
      await pump(tester, [_record(100, DateTime(2026, 9, 2))]);

      expect(
        find.text('Log at least two sessions to see your progress.'),
        findsOneWidget,
      );
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('draws every record in ALL by default', (tester) async {
      await pump(tester, [
        _record(100, DateTime(2025, 1, 10)),
        _record(110, DateTime(2026, 9, 2)),
        _record(120, DateTime(2026, 9, 20)),
      ]);

      expect(chart(tester).data.lineBarsData.single.spots, hasLength(3));
    });

    testWidgets('switching range filters the points', (tester) async {
      await pump(tester, [
        _record(100, DateTime(2025, 1, 10)),
        _record(110, DateTime(2026, 9, 2)),
        _record(120, DateTime(2026, 9, 20)),
      ]);

      await tester.tap(find.byKey(const Key('range-3M')));
      await tester.pumpAndSettle();

      expect(chart(tester).data.lineBarsData.single.spots, hasLength(2));
    });

    testWidgets('explains an empty range when there is data elsewhere', (
      tester,
    ) async {
      await pump(tester, [
        _record(100, DateTime(2024, 1, 10)),
        _record(110, DateTime(2024, 3, 5)),
      ]);

      await tester.tap(find.byKey(const Key('range-1Y')));
      await tester.pumpAndSettle();

      expect(find.text('Not enough entries in this range.'), findsOneWidget);
    });

    testWidgets('PR points get a bigger accent dot', (tester) async {
      final first = _record(100, DateTime(2026, 9, 2));
      final pr = _record(120, DateTime(2026, 9, 10));
      await pump(tester, [first, pr], prs: Set.identity()..add(pr));

      final bar = chart(tester).data.lineBarsData.single;
      FlDotCirclePainter dot(int i) =>
          bar.dotData.getDotPainter(bar.spots[i], 0, bar, i)
              as FlDotCirclePainter;

      expect(dot(0).radius, 3);
      expect(dot(1).radius, 5);
    });

    testWidgets('describes the trend for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, [
        _record(100, DateTime(2026, 9, 2)),
        _record(120, DateTime(2026, 9, 10)),
      ]);

      expect(
        find.bySemanticsLabel(
          'Progress chart: 1RM from 100.0 kg to 120.0 kg over 2 entries',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('does not animate with reduced motion', (tester) async {
      await pump(tester, [
        _record(100, DateTime(2026, 9, 2)),
        _record(120, DateTime(2026, 9, 10)),
      ], reduceMotion: true);

      expect(chart(tester).duration, Duration.zero);
    });

    testWidgets('two entries at the same instant still render', (tester) async {
      final when = DateTime(2026, 9, 10, 8);
      await pump(tester, [_record(100, when), _record(105, when)]);

      expect(tester.takeException(), isNull);
      expect(chart(tester).data.maxX, greaterThan(chart(tester).data.minX));
    });
  });
}
