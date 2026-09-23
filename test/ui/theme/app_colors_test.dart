import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_colors.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('contrast helper', () {
    test('black on white is 21:1', () {
      expect(contrast(Colors.black, Colors.white), closeTo(21, 0.01));
    });

    test('same color is 1:1', () {
      expect(contrast(AppColors.accent, AppColors.accent), closeTo(1, 0.001));
    });
  });

  group('AppColors meets WCAG AA (4.5:1) for text', () {
    const backgrounds = {
      'background': AppColors.background,
      'surface': AppColors.surface,
      'surfaceRaised': AppColors.surfaceRaised,
    };
    const foregrounds = {
      'textPrimary': AppColors.textPrimary,
      'textSecondary': AppColors.textSecondary,
      'textMuted': AppColors.textMuted,
      'accent': AppColors.accent,
      'error': AppColors.error,
    };

    for (final bg in backgrounds.entries) {
      for (final fg in foregrounds.entries) {
        test('${fg.key} on ${bg.key}', () {
          expect(contrast(fg.value, bg.value), greaterThanOrEqualTo(4.5));
        });
      }
    }

    test('onAccent on accent', () {
      expect(
        contrast(AppColors.onAccent, AppColors.accent),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  test('surfaces step up in lightness', () {
    expect(
      _luminance(AppColors.surface),
      greaterThan(_luminance(AppColors.background)),
    );
    expect(
      _luminance(AppColors.surfaceRaised),
      greaterThan(_luminance(AppColors.surface)),
    );
    expect(
      _luminance(AppColors.outline),
      greaterThan(_luminance(AppColors.surfaceRaised)),
    );
  });
}
