import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/onboarding_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

import 'helpers/test_app.dart';

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
          library: testLibrary(),
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
          library: testLibrary(),
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
          library: testLibrary(),
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
          library: testLibrary(),
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
          library: testLibrary(),
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
          library: testLibrary(),
          onboarding: onboarding,
          unitService: unitService,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OneRMApp — unit from onboarding', () {
    Future<UnitService> finishOnboarding(
      WidgetTester tester, {
      String? countryCode,
      bool pickLbs = false,
    }) async {
      final unitService = UnitService.forTesting();
      await tester.pumpWidget(
        OneRMApp(
          records: RecordsRepository(StorageService.inMemoryForTesting()),
          library: testLibrary(),
          onboarding: OnboardingService.forTesting(),
          unitService: unitService,
          countryCode: countryCode,
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('onboarding-next-button')));
        await tester.pumpAndSettle();
      }
      if (pickLbs) {
        await tester.tap(find.byKey(const Key('unit-option-lbs')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      return unitService;
    }

    testWidgets('US devices default to lbs', (tester) async {
      final units = await finishOnboarding(tester, countryCode: 'US');
      expect(await units.getUnit(), WeightUnit.lbs);
    });

    testWidgets('other regions default to kg', (tester) async {
      final units = await finishOnboarding(tester, countryCode: 'ES');
      expect(await units.getUnit(), WeightUnit.kg);
    });

    testWidgets('the unit picked during onboarding is saved', (tester) async {
      final units = await finishOnboarding(
        tester,
        countryCode: 'ES',
        pickLbs: true,
      );
      expect(await units.getUnit(), WeightUnit.lbs);
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
