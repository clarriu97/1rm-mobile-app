import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';
import 'package:one_rm_mobile/ui/widgets/sparkline.dart';

import '../../helpers/test_app.dart';

void main() {
  Finder painter() => find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is SparklinePainter,
  );

  group('Sparkline', () {
    testWidgets('draws nothing with no or one value but keeps its size', (
      tester,
    ) async {
      for (final values in [
        <double>[],
        <double>[100],
      ]) {
        await tester.pumpWidget(
          buildTestApp(Center(child: Sparkline(values: values))),
        );
        expect(painter(), findsNothing);
        expect(tester.getSize(find.byType(Sparkline)), const Size(72, 24));
      }
    });

    testWidgets('paints two or more values and hides from semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const Center(child: Sparkline(values: [100, 110]))),
      );

      expect(painter(), findsOneWidget);
      expect(
        find.ancestor(of: painter(), matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
    });
  });

  group('SparklinePainter.pointsFor', () {
    const size = Size(100, 30);

    test('rising series goes from bottom-left to top-right', () {
      const p = SparklinePainter(
        values: [100, 150, 200],
        color: AppColors.accent,
      );
      final points = p.pointsFor(size);

      expect(points.first, const Offset(3, 27));
      expect(points.last, const Offset(97, 3));
      expect(points[1].dy, closeTo(15, 0.001));
    });

    test('points are evenly spaced horizontally', () {
      const p = SparklinePainter(values: [1, 5, 2, 8], color: AppColors.accent);
      final xs = p.pointsFor(size).map((o) => o.dx).toList();

      expect(xs[1] - xs[0], closeTo(xs[2] - xs[1], 0.001));
      expect(xs[3] - xs[2], closeTo(xs[1] - xs[0], 0.001));
    });

    test('flat series is drawn along the middle without dividing by zero', () {
      const p = SparklinePainter(
        values: [120, 120, 120],
        color: AppColors.accent,
      );
      for (final point in p.pointsFor(size)) {
        expect(point.dy, 15);
        expect(point.dx.isFinite, isTrue);
      }
    });

    test('repaints only when values or color change', () {
      const p = SparklinePainter(values: [1, 2], color: AppColors.accent);
      expect(
        p.shouldRepaint(
          const SparklinePainter(values: [1, 2], color: AppColors.accent),
        ),
        isFalse,
      );
      expect(
        p.shouldRepaint(
          const SparklinePainter(values: [1, 3], color: AppColors.accent),
        ),
        isTrue,
      );
      expect(
        p.shouldRepaint(
          const SparklinePainter(values: [1, 2, 3], color: AppColors.accent),
        ),
        isTrue,
      );
      expect(
        p.shouldRepaint(
          const SparklinePainter(values: [1, 2], color: AppColors.error),
        ),
        isTrue,
      );
    });
  });
}
