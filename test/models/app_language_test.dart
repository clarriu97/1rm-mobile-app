import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/l10n/app_localizations.dart';
import 'package:one_rm_mobile/models/app_language.dart';

void main() {
  group('AppLanguage', () {
    test('system follows the device', () {
      expect(AppLanguage.system.locale, isNull);
    });

    test('each language forces its locale', () {
      expect(AppLanguage.en.locale, const Locale('en'));
      expect(AppLanguage.es.locale, const Locale('es'));
    });

    test('every language the app is translated to can be picked', () {
      expect(
        AppLanguage.values.map((l) => l.locale).nonNulls.toSet(),
        AppLocalizations.supportedLocales.toSet(),
      );
    });
  });
}
