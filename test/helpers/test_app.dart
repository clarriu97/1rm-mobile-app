import 'package:flutter/material.dart';
import 'package:one_rm_mobile/l10n/app_localizations.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/language_repository.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/services/language_service.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';

/// Wraps [home] in a MaterialApp with the app theme and localizations
/// (English unless [locale] says otherwise). Pass [platform] to exercise
/// platform-specific behavior such as the iOS back swipe.
Widget buildTestApp(Widget home, {TargetPlatform? platform, Locale? locale}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark.copyWith(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('en'),
      home: home,
    );

/// Exercise library backed by an in-memory fake.
ExerciseLibrary testLibrary({Set<String> hidden = const {}}) => ExerciseLibrary(
  ExerciseLibraryService.forTesting(hidden: hidden),
  hidden: hidden,
);

/// Language choice backed by an in-memory fake; follows the device.
LanguageRepository testLanguage() =>
    LanguageRepository(LanguageService.forTesting());
