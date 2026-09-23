import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_theme.dart';

void main() {
  final theme = AppTheme.dark;
  final text = theme.textTheme;

  group('AppTheme typography', () {
    final displayStyles = {
      'displayLarge': text.displayLarge,
      'displayMedium': text.displayMedium,
      'displaySmall': text.displaySmall,
      'headlineMedium': text.headlineMedium,
      'titleLarge': text.titleLarge,
    };
    final bodyStyles = {
      'titleMedium': text.titleMedium,
      'titleSmall': text.titleSmall,
      'bodyLarge': text.bodyLarge,
      'bodyMedium': text.bodyMedium,
      'bodySmall': text.bodySmall,
      'labelLarge': text.labelLarge,
      'labelMedium': text.labelMedium,
      'labelSmall': text.labelSmall,
    };

    for (final entry in displayStyles.entries) {
      test('${entry.key} uses Big Shoulders with a matching wght axis', () {
        final style = entry.value!;
        expect(style.fontFamily, AppTheme.displayFont);
        expect(
          style.fontVariations,
          contains(FontVariation.weight(style.fontWeight!.value.toDouble())),
        );
      });
    }

    for (final entry in bodyStyles.entries) {
      test('${entry.key} uses Barlow with tabular figures', () {
        final style = entry.value!;
        expect(style.fontFamily, AppTheme.bodyFont);
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });
    }

    test('hero number is the largest style', () {
      final sizes = [
        ...displayStyles.values,
        ...bodyStyles.values,
      ].map((s) => s!.fontSize!).toList();
      expect(
        text.displayLarge!.fontSize,
        sizes.reduce((a, b) => a > b ? a : b),
      );
    });
  });

  group('AppTheme components', () {
    test('uses the iron & chalk palette', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.accent);
      expect(theme.colorScheme.onPrimary, AppColors.onAccent);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('primary buttons are at least 56 dp tall and full width', () {
      final size = theme.elevatedButtonTheme.style!.minimumSize!.resolve({});
      expect(size!.height, greaterThanOrEqualTo(56));
      expect(size.width, double.infinity);
    });

    test('text buttons meet the minimum tap target', () {
      final size = theme.textButtonTheme.style!.minimumSize!.resolve({});
      expect(size!.height, greaterThanOrEqualTo(kMinTapTarget));
      expect(size.width, greaterThanOrEqualTo(kMinTapTarget));
    });

    test('date picker uses the tight radius and display font', () {
      final picker = theme.datePickerTheme;
      final shape = picker.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadii.md));
      expect(picker.headerHeadlineStyle!.fontFamily, AppTheme.displayFont);
    });

    test('focused inputs are outlined in the accent color', () {
      final border =
          theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.accent);
    });
  });
}
