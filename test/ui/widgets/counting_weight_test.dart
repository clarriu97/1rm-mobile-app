import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';
import 'package:one_rm_mobile/ui/widgets/counting_weight.dart';

import '../../helpers/test_app.dart';

void main() {
  Widget weight(
    double kg, {
    bool reduceMotion = false,
    Locale? locale,
    WeightUnit unit = WeightUnit.kg,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: buildTestApp(
      Scaffold(
        body: CountingWeight(weightInKg: kg, unit: unit),
      ),
      locale: locale,
    ),
  );

  double shown(WidgetTester tester) => double.parse(
    tester
        .widget<Text>(find.byType(Text))
        .data!
        .split(' ')
        .first
        .replaceAll(',', '.'),
  );

  group('CountingWeight', () {
    testWidgets('counts up from zero when it appears', (tester) async {
      await tester.pumpWidget(weight(140));
      expect(shown(tester), 0);

      await tester.pump(AppMotion.long ~/ 2);
      expect(shown(tester), inExclusiveRange(0, 140));

      await tester.pumpAndSettle();
      expect(find.text('140.0 kg'), findsOneWidget);
    });

    testWidgets('a new value counts from the old one, not from zero', (
      tester,
    ) async {
      await tester.pumpWidget(weight(140));
      await tester.pumpAndSettle();

      await tester.pumpWidget(weight(150));
      await tester.pump(AppMotion.long ~/ 2);
      expect(shown(tester), inExclusiveRange(140, 150));

      await tester.pumpAndSettle();
      expect(find.text('150.0 kg'), findsOneWidget);
    });

    testWidgets('with reduced motion it shows the value at once', (
      tester,
    ) async {
      await tester.pumpWidget(weight(140, reduceMotion: true));
      expect(find.text('140.0 kg'), findsOneWidget);

      await tester.pumpWidget(weight(150, reduceMotion: true));
      expect(find.text('150.0 kg'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('screen readers hear only the final value', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(weight(140));

      expect(find.bySemanticsLabel('140.0 kg'), findsOneWidget);
      expect(find.bySemanticsLabel('0.0 kg'), findsNothing);

      await tester.pumpAndSettle();
      semantics.dispose();
    });

    testWidgets('in the language and unit of the app', (tester) async {
      await tester.pumpWidget(
        weight(100, locale: const Locale('es'), unit: WeightUnit.lbs),
      );
      await tester.pumpAndSettle();
      expect(find.text('220,5 lbs'), findsOneWidget);
    });
  });
}
