import 'package:flutter/material.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';

/// Wraps [home] in a MaterialApp with the app theme. Pass [platform] to
/// exercise platform-specific behavior such as the iOS back swipe.
Widget buildTestApp(Widget home, {TargetPlatform? platform}) => MaterialApp(
  theme: AppTheme.dark.copyWith(platform: platform),
  home: home,
);
