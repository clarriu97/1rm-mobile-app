import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/services/onboarding_service.dart';

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
}
