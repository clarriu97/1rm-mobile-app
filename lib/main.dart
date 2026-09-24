import 'dart:ui';

import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'repositories/exercise_library.dart';
import 'repositories/language_repository.dart';
import 'repositories/records_repository.dart';
import 'services/exercise_library_service.dart';
import 'services/language_service.dart';
import 'services/onboarding_service.dart';
import 'services/storage_service.dart';
import 'services/unit_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/font_licenses.dart';
import 'ui/home_screen.dart';
import 'ui/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  runApp(await loadApp());
}

/// Builds the app on top of the on-device services. Integration tests use it
/// too, so they exercise the same composition as a real launch.
Future<OneRMApp> loadApp() async {
  final records = await RecordsRepository.load(
    await StorageService.getInstance(),
  );
  final library = await ExerciseLibrary.load(
    await ExerciseLibraryService.getInstance(),
  );
  final onboarding = await OnboardingService.getInstance();
  final unitService = await UnitService.getInstance();
  final language = await LanguageRepository.load(
    await LanguageService.getInstance(),
  );

  return OneRMApp(
    records: records,
    library: library,
    onboarding: onboarding,
    unitService: unitService,
    language: language,
    countryCode: PlatformDispatcher.instance.locale.countryCode,
  );
}

class OneRMApp extends StatelessWidget {
  const OneRMApp({
    super.key,
    required this.records,
    required this.library,
    required this.onboarding,
    required this.unitService,
    required this.language,
    this.countryCode,
  });

  final RecordsRepository records;
  final ExerciseLibrary library;
  final OnboardingService onboarding;
  final UnitService unitService;
  final LanguageRepository language;

  /// Device region, used to pick the default unit during onboarding.
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: language,
      builder: (context, _) => MaterialApp(
        title: '1RM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: language.language.locale,
        home: _AppGate(
          onboarding: onboarding,
          records: records,
          library: library,
          unitService: unitService,
          language: language,
          countryCode: countryCode,
        ),
      ),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate({
    required this.onboarding,
    required this.records,
    required this.library,
    required this.unitService,
    required this.language,
    required this.countryCode,
  });

  final OnboardingService onboarding;
  final RecordsRepository records;
  final ExerciseLibrary library;
  final UnitService unitService;
  final LanguageRepository language;
  final String? countryCode;

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final complete = await widget.onboarding.isOnboardingComplete();
    if (mounted) setState(() => _onboardingComplete = complete);
  }

  Future<void> _completeOnboarding(OnboardingChoices choices) async {
    await widget.unitService.setUnit(choices.unit);
    final lifts = choices.lifts;
    if (lifts != null) await widget.library.setVisibleExactly(lifts);
    await widget.onboarding.completeOnboarding();
    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingComplete!) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
        initialUnit: defaultUnitForCountry(widget.countryCode),
        exercises: widget.library.all,
        initialLifts: {for (final e in widget.library.visible) e.id},
      );
    }

    return HomeScreen(
      records: widget.records,
      library: widget.library,
      unitService: widget.unitService,
      language: widget.language,
    );
  }
}
