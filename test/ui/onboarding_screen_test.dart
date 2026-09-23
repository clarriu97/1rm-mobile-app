import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders first page with title and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('What is 1RM?'), findsOneWidget);
      expect(find.textContaining('One-Rep Max'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
      expect(find.textContaining('Epley formula'), findsOneWidget);
    });

    testWidgets('navigates to third page on second Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Train smarter'), findsOneWidget);
      expect(find.textContaining('working weights'), findsOneWidget);
    });

    testWidgets('shows Get Started on last page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('hides Skip button on last page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      final skip = tester.widget<Visibility>(
        find.ancestor(of: find.text('Skip'), matching: find.byType(Visibility)),
      );
      expect(skip.visible, isFalse);
      expect(find.text('Skip').hitTestable(), findsNothing);
    });

    testWidgets('calls onComplete when Get Started is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('calls onComplete when Skip is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('swipe navigates to next page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
    });

    testWidgets('renders 3 page indicators', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('each page shows its own illustration', (tester) async {
      Finder illustration(String name) => find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            (w.bytesLoader as SvgAssetLoader).assetName ==
                'assets/illustrations/$name.svg',
      );

      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );
      expect(illustration('onboarding_max'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      expect(illustration('onboarding_log'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      expect(illustration('onboarding_table'), findsOneWidget);
    });
  });

  group('defaultUnitForCountry', () {
    test('pounds for countries that do not use the metric system', () {
      for (final code in ['US', 'us', 'LR', 'MM']) {
        expect(defaultUnitForCountry(code), WeightUnit.lbs, reason: code);
      }
    });

    test('kilograms everywhere else and when unknown', () {
      for (final code in ['ES', 'GB', 'MX', 'CA', '', null]) {
        expect(defaultUnitForCountry(code), WeightUnit.kg, reason: '$code');
      }
    });
  });

  group('OnboardingScreen — unit choice', () {
    Future<void> goToLastPage(WidgetTester tester) async {
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('onboarding-next-button')));
        await tester.pumpAndSettle();
      }
    }

    bool isSelected(WidgetTester tester, WeightUnit unit) => tester
        .widget<Semantics>(
          find
              .ancestor(
                of: find.byKey(Key('unit-option-${unit.name}')),
                matching: find.byType(Semantics),
              )
              .first,
        )
        .properties
        .selected!;

    testWidgets('last page preselects the initial unit', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          OnboardingScreen(onComplete: (_) {}, initialUnit: WeightUnit.lbs),
        ),
      );
      await goToLastPage(tester);

      expect(find.text('KG'), findsOneWidget);
      expect(find.text('LBS'), findsOneWidget);
      expect(isSelected(tester, WeightUnit.lbs), isTrue);
      expect(isSelected(tester, WeightUnit.kg), isFalse);
    });

    testWidgets('choosing a unit and finishing reports it', (tester) async {
      WeightUnit? chosen;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (u) => chosen = u)),
      );
      await goToLastPage(tester);

      await tester.tap(find.byKey(const Key('unit-option-lbs')));
      await tester.pump();
      expect(isSelected(tester, WeightUnit.lbs), isTrue);

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pump();
      expect(chosen, WeightUnit.lbs);
    });

    testWidgets('skipping keeps the initial unit', (tester) async {
      WeightUnit? chosen;
      await tester.pumpWidget(
        buildTestApp(
          OnboardingScreen(
            onComplete: (u) => chosen = u,
            initialUnit: WeightUnit.lbs,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pump();
      expect(chosen, WeightUnit.lbs);
    });
  });
}
