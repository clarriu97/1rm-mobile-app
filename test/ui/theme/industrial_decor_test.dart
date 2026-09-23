import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';

import '../../helpers/test_app.dart';

void main() {
  group('KnurlPanel', () {
    testWidgets('renders its child over the knurl texture', (tester) async {
      await tester.pumpWidget(buildTestApp(const KnurlPanel(child: Text('X'))));

      expect(find.text('X'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is KnurlPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('paints without errors at zero size', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Center(
            child: SizedBox.shrink(
              child: KnurlPanel(padding: EdgeInsets.zero, child: SizedBox()),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('KnurlPainter', () {
    test('repaints only when spacing or color change', () {
      const painter = KnurlPainter();
      expect(painter.shouldRepaint(const KnurlPainter()), isFalse);
      expect(painter.shouldRepaint(const KnurlPainter(spacing: 10)), isTrue);
      expect(
        painter.shouldRepaint(const KnurlPainter(color: Colors.red)),
        isTrue,
      );
    });
  });

  group('HazardStripe', () {
    testWidgets('is decorative and hidden from screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestApp(const Column(children: [HazardStripe(), Text('label')])),
      );

      expect(find.byType(HazardStripe), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HazardStripe),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('uses the requested height and fills the width', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const Column(children: [HazardStripe(height: 10)])),
      );

      final size = tester.getSize(find.byType(HazardStripe));
      expect(size.height, 10);
      expect(
        size.width,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
    });
  });
}
