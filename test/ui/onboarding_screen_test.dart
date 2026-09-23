import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders first page with title and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      expect(find.text('What is 1RM?'), findsOneWidget);
      expect(find.textContaining('One-Rep Max'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
      expect(find.textContaining('Epley formula'), findsOneWidget);
    });

    testWidgets('navigates to third page on second Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Train smarter'), findsOneWidget);
      expect(find.textContaining('percentage table'), findsOneWidget);
    });

    testWidgets('shows Get Started on last page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
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
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('calls onComplete when Get Started is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () => completed = true)),
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
        buildTestApp(OnboardingScreen(onComplete: () => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('swipe navigates to next page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
      );

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
    });

    testWidgets('renders 3 page indicators', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: () {})),
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
        buildTestApp(OnboardingScreen(onComplete: () {})),
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
}
