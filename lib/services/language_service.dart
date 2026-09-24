import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_language.dart';

abstract class LanguageService {
  Future<AppLanguage> getLanguage();
  Future<void> setLanguage(AppLanguage language);

  static Future<LanguageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return _LanguageServiceImpl(prefs);
  }

  static LanguageService forTesting({
    AppLanguage language = AppLanguage.system,
  }) => _FakeLanguageService(language);
}

class _LanguageServiceImpl implements LanguageService {
  _LanguageServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'app_language';

  @override
  Future<AppLanguage> getLanguage() async {
    final value = _prefs.getString(_key);
    return AppLanguage.values.firstWhere(
      (l) => l.name == value,
      orElse: () => AppLanguage.system,
    );
  }

  @override
  Future<void> setLanguage(AppLanguage language) =>
      _prefs.setString(_key, language.name);
}

class _FakeLanguageService implements LanguageService {
  _FakeLanguageService(this._language);

  AppLanguage _language;

  @override
  Future<AppLanguage> getLanguage() async => _language;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
  }
}
