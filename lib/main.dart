import 'package:flutter/material.dart';
import 'models/exercise.dart';
import 'services/onboarding_service.dart';
import 'services/storage_service.dart';
import 'services/unit_service.dart';
import 'ui/app_theme.dart';
import 'ui/home_screen.dart';
import 'ui/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.getInstance();
  final initialRecords = await storage.load();
  final onboarding = await OnboardingService.getInstance();
  final unitService = await UnitService.getInstance();

  runApp(
    OneRMApp(
      initialRecords: initialRecords,
      storage: storage,
      onboarding: onboarding,
      unitService: unitService,
    ),
  );
}

class OneRMApp extends StatelessWidget {
  const OneRMApp({
    super.key,
    required this.initialRecords,
    required this.storage,
    required this.onboarding,
    required this.unitService,
  });

  final Map<String, List<ExerciseRecord>> initialRecords;
  final StorageService storage;
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
        initialRecords: initialRecords,
        storage: storage,
        unitService: unitService,
      ),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate({
    required this.onboarding,
    required this.initialRecords,
    required this.storage,
    required this.unitService,
  });

  final OnboardingService onboarding;
  final Map<String, List<ExerciseRecord>> initialRecords;
  final StorageService storage;
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
      initialRecords: widget.initialRecords,
      storage: widget.storage,
      unitService: widget.unitService,
    );
  }
}
