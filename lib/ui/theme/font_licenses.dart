import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts are OFL-licensed; the license must ship with the app.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, asset) in const [
      ('Big Shoulders Display', 'assets/fonts/OFL-BigShouldersDisplay.txt'),
      ('Barlow', 'assets/fonts/OFL-Barlow.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString(asset));
    }
  });
}
