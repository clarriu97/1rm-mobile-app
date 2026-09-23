import 'package:flutter/material.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';

/// Wraps [home] in a MaterialApp with the app theme. Pass [platform] to
/// exercise platform-specific behavior such as the iOS back swipe.
Widget buildTestApp(Widget home, {TargetPlatform? platform}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark.copyWith(platform: platform),
  home: home,
);

/// Exercise library backed by an in-memory fake.
ExerciseLibrary testLibrary({Set<String> hidden = const {}}) => ExerciseLibrary(
  ExerciseLibraryService.forTesting(hidden: hidden),
  hidden: hidden,
);
