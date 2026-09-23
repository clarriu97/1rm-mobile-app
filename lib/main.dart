import 'package:flutter/material.dart';
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
  });

  final RecordsRepository records;
  final ExerciseLibrary library;
  final OnboardingService onboarding;
  final UnitService unitService;

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
  });

  final OnboardingService onboarding;
  final RecordsRepository records;
  final ExerciseLibrary library;
  final UnitService unitService;

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

  Future<void> _completeOnboarding() async {
    await widget.onboarding.completeOnboarding();
    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingComplete!) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return HomeScreen(
      records: widget.records,
      library: widget.library,
      unitService: widget.unitService,
    );
  }
}
