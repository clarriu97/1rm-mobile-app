import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/app_language.dart';
import 'package:one_rm_mobile/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LanguageService', () {
    test('follows the device until the user picks a language', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await LanguageService.getInstance();
      expect(await service.getLanguage(), AppLanguage.system);
    });

    test('saves the choice across instances', () async {
      SharedPreferences.setMockInitialValues({});
      await (await LanguageService.getInstance()).setLanguage(AppLanguage.es);

      final reopened = await LanguageService.getInstance();
      expect(await reopened.getLanguage(), AppLanguage.es);

      await reopened.setLanguage(AppLanguage.system);
      expect(
        await (await LanguageService.getInstance()).getLanguage(),
        AppLanguage.system,
      );
    });

    test('an unknown stored value falls back to the device language', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'fr'});
      final service = await LanguageService.getInstance();
      expect(await service.getLanguage(), AppLanguage.system);
    });

    test('the fake starts where told and remembers changes', () async {
      final service = LanguageService.forTesting(language: AppLanguage.en);
      expect(await service.getLanguage(), AppLanguage.en);
      await service.setLanguage(AppLanguage.es);
      expect(await service.getLanguage(), AppLanguage.es);
    });
  });
}
