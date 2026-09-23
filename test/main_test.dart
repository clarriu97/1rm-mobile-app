import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/onboarding_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

void main() {
  group('OneRMApp onboarding gate', () {
    late RecordsRepository records;

    setUp(() {
      records = RecordsRepository(StorageService.inMemoryForTesting());
    });

    testWidgets('shows onboarding when not completed', (tester) async {
      final onboarding = OnboardingService.forTesting();
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        OneRMApp(
          records: records,
          onboarding: onboarding,
          unitService: unitService,
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
