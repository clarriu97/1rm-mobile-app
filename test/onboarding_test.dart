import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/services/onboarding_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(theme: AppTheme.dark, home: home);
}

void main() {
  group('OnboardingService (fake)', () {
    test('isOnboardingComplete returns false by default', () async {
      final service = OnboardingService.forTesting();
      expect(await service.isOnboardingComplete(), isFalse);
    });

    test('isOnboardingComplete returns true when pre-completed', () async {
      final service = OnboardingService.forTesting(completed: true);
      expect(await service.isOnboardingComplete(), isTrue);
    });

    test('completeOnboarding sets state to true', () async {
      final service = OnboardingService.forTesting();
      expect(await service.isOnboardingComplete(), isFalse);

      await service.completeOnboarding();
      expect(await service.isOnboardingComplete(), isTrue);
    });

    test('completeOnboarding is idempotent', () async {
      final service = OnboardingService.forTesting();
      await service.completeOnboarding();
      await service.completeOnboarding();
      expect(await service.isOnboardingComplete(), isTrue);
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders first page with title and description', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      expect(find.text('What is 1RM?'), findsOneWidget);
      expect(find.textContaining('One-Rep Max'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
      expect(find.textContaining('Epley formula'), findsOneWidget);
    });

    testWidgets('navigates to third page on second Next tap', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Train smarter'), findsOneWidget);
      expect(find.textContaining('percentage table'), findsOneWidget);
    });

    testWidgets('shows Get Started on last page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('hides Skip button on last page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('calls onComplete when Get Started is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        _buildApp(OnboardingScreen(onComplete: () => completed = true)),
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
        _buildApp(OnboardingScreen(onComplete: () => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('swipe navigates to next page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
    });

    testWidgets('renders 3 page indicators', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders fitness_center icon on first page', (tester) async {
      await tester.pumpWidget(_buildApp(OnboardingScreen(onComplete: () {})));

      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });
  });

  group('OneRMApp onboarding gate', () {
    late StorageService storage;

    setUp(() async {
      storage = await StorageService.getInstanceForTesting();
    });

    testWidgets('shows onboarding when not completed', (tester) async {
      final onboarding = OnboardingService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('What is 1RM?'), findsOneWidget);
    });

    testWidgets('shows home screen when onboarding already completed', (
      tester,
    ) async {
      final onboarding = OnboardingService.forTesting(completed: true);

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('1RM'), findsOneWidget);
    });

    testWidgets('transitions from onboarding to home after completing', (
      tester,
    ) async {
      final onboarding = OnboardingService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('1RM'), findsOneWidget);
    });

    testWidgets('transitions from onboarding to home after Get Started', (
      tester,
    ) async {
      final onboarding = OnboardingService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('1RM'), findsOneWidget);
    });

    testWidgets('persists onboarding completion via service', (tester) async {
      final onboarding = OnboardingService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(await onboarding.isOnboardingComplete(), isFalse);

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(await onboarding.isOnboardingComplete(), isTrue);
    });

    testWidgets('shows loading indicator while checking onboarding state', (
      tester,
    ) async {
      final onboarding = _SlowOnboardingService();

      await tester.pumpWidget(
        OneRMApp(
          initialRecords: const {},
          storage: storage,
          onboarding: onboarding,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}

class _SlowOnboardingService implements OnboardingService {
  final _completer = Completer<bool>();

  @override
  Future<bool> isOnboardingComplete() => _completer.future;

  @override
  Future<void> completeOnboarding() async {}
}
