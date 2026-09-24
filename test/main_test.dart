import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/services/language_service.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/models/app_language.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/language_repository.dart';
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
          language: testLanguage(),
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
          language: testLanguage(),
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
          language: testLanguage(),
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
          language: testLanguage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
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
          language: testLanguage(),
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
          language: testLanguage(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OneRMApp — language', () {
    Future<void> pumpIn(
      WidgetTester tester,
      Locale locale, {
      LanguageRepository? language,
      bool onboarded = false,
    }) async {
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(
        OneRMApp(
          records: RecordsRepository(StorageService.inMemoryForTesting()),
          library: testLibrary(),
          onboarding: OnboardingService.forTesting(completed: onboarded),
          unitService: UnitService.forTesting(),
          language: language ?? testLanguage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    LanguageRepository chosen(AppLanguage language) => LanguageRepository(
      LanguageService.forTesting(language: language),
      language: language,
    );

    testWidgets('a language picked in Settings wins over the device', (
      tester,
    ) async {
      await pumpIn(
        tester,
        const Locale('en', 'US'),
        language: chosen(AppLanguage.es),
      );
      expect(find.text('¿Qué es el 1RM?'), findsOneWidget);
    });

    testWidgets('English can be forced on a Spanish device', (tester) async {
      await pumpIn(
        tester,
        const Locale('es', 'ES'),
        language: chosen(AppLanguage.en),
      );
      expect(find.text('What is 1RM?'), findsOneWidget);
    });

    testWidgets('changing it in Settings switches the whole app at once, '
        'and back to the device language', (tester) async {
      final language = testLanguage();
      await pumpIn(
        tester,
        const Locale('fr', 'FR'),
        language: language,
        onboarded: true,
      );
      expect(find.text('No records yet'), findsWidgets);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('language-es')));
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Aún no hay registros'), findsWidgets);

      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('language-system')));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(language.language, AppLanguage.system);
    });

    testWidgets('follows a Spanish system language', (tester) async {
      await pumpIn(tester, const Locale('es', 'ES'));
      expect(find.text('¿Qué es el 1RM?'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('Spanish from any region is Spanish', (tester) async {
      await pumpIn(tester, const Locale('es', 'MX'));
      expect(find.text('¿Qué es el 1RM?'), findsOneWidget);
    });

    testWidgets('English system language', (tester) async {
      await pumpIn(tester, const Locale('en', 'GB'));
      expect(find.text('What is 1RM?'), findsOneWidget);
    });

    testWidgets('an unsupported language falls back to English', (
      tester,
    ) async {
      await pumpIn(tester, const Locale('fr', 'FR'));
      expect(find.text('What is 1RM?'), findsOneWidget);
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
          language: testLanguage(),
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
      // Unit page → lifts page → finish.
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('onboarding-next-button')));
        await tester.pumpAndSettle();
      }
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

  group('OneRMApp — lifts from onboarding', () {
    testWidgets('lifts picked during onboarding are the ones on Home', (
      tester,
    ) async {
      final library = testLibrary();
      await tester.pumpWidget(
        OneRMApp(
          records: RecordsRepository(StorageService.inMemoryForTesting()),
          library: library,
          onboarding: OnboardingService.forTesting(),
          unitService: UnitService.forTesting(),
          language: testLanguage(),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('onboarding-next-button')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('lift-chip-front_squat')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(library.isHidden('front_squat'), isTrue);
      expect(library.isHidden('back_squat'), isFalse);
      expect(find.text('Front Squat'), findsNothing);
      expect(find.text('Back Squat'), findsOneWidget);
    });

    testWidgets('skipping keeps the default lifts untouched', (tester) async {
      final service = ExerciseLibraryService.forTesting();
      await tester.pumpWidget(
        OneRMApp(
          records: RecordsRepository(StorageService.inMemoryForTesting()),
          library: ExerciseLibrary(service),
          onboarding: OnboardingService.forTesting(),
          unitService: UnitService.forTesting(),
          language: testLanguage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(await service.loadHidden(), isEmpty);
      expect(await service.loadShown(), isEmpty);
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
