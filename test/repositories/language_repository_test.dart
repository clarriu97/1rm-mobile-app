import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/app_language.dart';
import 'package:one_rm_mobile/repositories/language_repository.dart';
import 'package:one_rm_mobile/services/language_service.dart';

void main() {
  group('LanguageRepository', () {
    test('loads the saved choice', () async {
      final repository = await LanguageRepository.load(
        LanguageService.forTesting(language: AppLanguage.es),
      );
      expect(repository.language, AppLanguage.es);
    });

    test('a change notifies listeners and is saved', () async {
      final service = LanguageService.forTesting();
      final repository = LanguageRepository(service);
      var notified = 0;
      repository.addListener(() => notified++);

      await repository.setLanguage(AppLanguage.en);

      expect(repository.language, AppLanguage.en);
      expect(notified, 1);
      expect(await service.getLanguage(), AppLanguage.en);
    });

    test('picking the current language does nothing', () async {
      final service = LanguageService.forTesting(language: AppLanguage.es);
      final repository = LanguageRepository(service, language: AppLanguage.es);
      var notified = 0;
      repository.addListener(() => notified++);

      await repository.setLanguage(AppLanguage.es);

      expect(notified, 0);
    });
  });
}
