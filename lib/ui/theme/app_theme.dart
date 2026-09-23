import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

export 'app_colors.dart';
export 'app_tokens.dart';
export 'industrial_decor.dart';

class AppTheme {
  AppTheme._();

  static const String displayFont = 'BigShoulders';
  static const String bodyFont = 'Barlow';

  /// Big Shoulders is a variable font: the weight axis must be set explicitly.
  static TextStyle _display(
    double size,
    FontWeight weight, {
    double height = 1.0,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
    height: height,
    letterSpacing: letterSpacing,
    color: AppColors.textPrimary,
  );

  /// Barlow with tabular figures so numbers line up in columns.
  static TextStyle _body(
    double size,
    FontWeight weight, {
    Color color = AppColors.textSecondary,
    double? height,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: bodyFont,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextTheme textTheme = TextTheme(
    // Hero numbers (best 1RM).
    displayLarge: _display(80, FontWeight.w800, height: 0.9),
    // Onboarding titles.
    displayMedium: _display(44, FontWeight.w800),
    // Numbers on cards.
    displaySmall: _display(28, FontWeight.w800),
    headlineMedium: _display(32, FontWeight.w800),
    // App bar titles.
    titleLarge: _display(26, FontWeight.w800, letterSpacing: 0.5),
    titleMedium: _body(17, FontWeight.w600, color: AppColors.textPrimary),
    titleSmall: _body(15, FontWeight.w600, color: AppColors.textPrimary),
    bodyLarge: _body(16, FontWeight.w400, height: 1.45),
    bodyMedium: _body(14, FontWeight.w400, height: 1.4),
    bodySmall: _body(12, FontWeight.w500, color: AppColors.textMuted),
    labelLarge: _body(
      16,
      FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0.8,
    ),
    // Overlines — use with UPPERCASE text.
    labelMedium: _body(
      12,
      FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 1.6,
    ),
    labelSmall: _body(
      11,
      FontWeight.w600,
      color: AppColors.textMuted,
      letterSpacing: 1.2,
    ),
  );

  static ThemeData get dark {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceRaised,
        outline: AppColors.outline,
        error: AppColors.error,
      ),
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      dividerColor: AppColors.outline,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        border: inputBorder(AppColors.outline),
        enabledBorder: inputBorder(AppColors.outline),
        focusedBorder: inputBorder(AppColors.accent, 2),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 2),
        labelStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        suffixStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        prefixIconColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: shape,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 17),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        highlightElevation: 0,
        shape: shape,
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.onAccent,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.outline),
        ),
        titleTextStyle: textTheme.headlineMedium?.copyWith(fontSize: 26),
        contentTextStyle: textTheme.bodyLarge,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.outline),
        ),
        headerHeadlineStyle: textTheme.headlineMedium,
        dividerColor: AppColors.outline,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
    );
  }
}
