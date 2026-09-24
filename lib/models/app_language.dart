import 'dart:ui';

/// Language the user picked in Settings; [system] follows the device.
enum AppLanguage {
  system,
  en,
  es;

  /// The locale to force, or null to follow the device.
  Locale? get locale => this == system ? null : Locale(name);
}
