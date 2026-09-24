import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';
import 'package:one_rm_mobile/ui/widgets/staggered_list.dart';

import '../../helpers/test_app.dart';

void main() {
  Widget list(int count, {bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: buildTestApp(
      Scaffold(
        body: StaggeredList(
          children: [
            for (var i = 0; i < count; i++)
              SizedBox(key: Key('item-$i'), height: 20, child: Text('$i')),
          ],
        ),
      ),
    ),
  );

  double opacityOf(WidgetTester tester, int index) => tester
      .widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(Key('item-$index')),
              matching: find.byType(FadeTransition),
            )
            .first,
      )
      .opacity
      .value;

  group('StaggeredList', () {
    testWidgets('items appear one after another, then stay', (tester) async {
      await tester.pumpWidget(list(6));

      expect(opacityOf(tester, 0), 0);
      expect(opacityOf(tester, 5), 0);

      await tester.pump(AppMotion.long * 0.3);
      expect(opacityOf(tester, 0), greaterThan(opacityOf(tester, 5)));

      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        expect(opacityOf(tester, i), 1);
      }
    });

    testWidgets('every item has finished when the entrance ends, however '
        'long the list', (tester) async {
      await tester.pumpWidget(list(StaggeredList.maxStaggered + 5));
      await tester.pump(AppMotion.long);
      expect(opacityOf(tester, StaggeredList.maxStaggered + 4), 1);
    });

    testWidgets('with reduced motion everything is there at once', (
      tester,
    ) async {
      await tester.pumpWidget(list(6, reduceMotion: true));

      for (var i = 0; i < 6; i++) {
        expect(opacityOf(tester, i), 1);
      }
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('items added after the entrance appear at once', (
      tester,
    ) async {
      await tester.pumpWidget(list(2));
      await tester.pumpAndSettle();

      await tester.pumpWidget(list(3));

      expect(opacityOf(tester, 2), 1);
    });

    testWidgets('children keep their keys', (tester) async {
      await tester.pumpWidget(list(3));
      expect(find.byKey(const Key('item-1')), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
