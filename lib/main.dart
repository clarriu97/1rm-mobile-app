import 'dart:ui';

import 'package:flutter/material.dart';
import 'models/weight_unit.dart';
import 'repositories/exercise_library.dart';
import 'repositories/records_repository.dart';
import 'services/exercise_library_service.dart';
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
  final records = await RecordsRepository.load(
    await StorageService.getInstance(),
  );
  final library = await ExerciseLibrary.load(
    await ExerciseLibraryService.getInstance(),
  );
  final onboarding = await OnboardingService.getInstance();
  final unitService = await UnitService.getInstance();

  runApp(
    OneRMApp(
      records: records,
      library: library,
      onboarding: onboarding,
      unitService: unitService,
      countryCode: PlatformDispatcher.instance.locale.countryCode,
    ),
  );
}

class OneRMApp extends StatelessWidget {
  const OneRMApp({
    super.key,
    required this.records,
    required this.library,
    required this.onboarding,
    required this.unitService,
    this.countryCode,
  });

  final RecordsRepository records;
  final ExerciseLibrary library;
  final OnboardingService onboarding;
  final UnitService unitService;

  /// Device region, used to pick the default unit during onboarding.
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1RM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _AppGate(
        onboarding: onboarding,
        records: records,
        library: library,
        unitService: unitService,
        countryCode: countryCode,
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
    required this.countryCode,
  });

  final OnboardingService onboarding;
  final RecordsRepository records;
  final ExerciseLibrary library;
  final UnitService unitService;
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

  Future<void> _completeOnboarding(WeightUnit unit) async {
    await widget.unitService.setUnit(unit);
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
      );
    }

    return HomeScreen(
      records: widget.records,
      library: widget.library,
      unitService: widget.unitService,
    );
  }
}
