import 'package:flutter/foundation.dart';
import '../models/app_language.dart';
import '../services/language_service.dart';

/// The app's language choice. The whole app rebuilds when it changes.
class LanguageRepository extends ChangeNotifier {
  LanguageRepository(this._service, {AppLanguage language = AppLanguage.system})
    : _language = language;

  static Future<LanguageRepository> load(LanguageService service) async =>
      LanguageRepository(service, language: await service.getLanguage());

  final LanguageService _service;
  AppLanguage _language;

  AppLanguage get language => _language;

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    await _service.setLanguage(language);
  }
}
