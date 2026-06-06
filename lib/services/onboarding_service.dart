import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingService {
  Future<bool> isOnboardingComplete();
  Future<void> completeOnboarding();

  static Future<OnboardingService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return _OnboardingServiceImpl(prefs);
  }

  static OnboardingService forTesting({bool completed = false}) =>
      _FakeOnboardingService(completed: completed);
}

class _OnboardingServiceImpl implements OnboardingService {
  _OnboardingServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'onboarding_complete';

  @override
  Future<bool> isOnboardingComplete() async => _prefs.getBool(_key) ?? false;

  @override
  Future<void> completeOnboarding() => _prefs.setBool(_key, true);
}

class _FakeOnboardingService implements OnboardingService {
  _FakeOnboardingService({bool completed = false}) : _completed = completed;

  bool _completed;

  @override
  Future<bool> isOnboardingComplete() async => _completed;

  @override
  Future<void> completeOnboarding() async {
    _completed = true;
  }
}
