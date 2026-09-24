import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
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
  group('AppTheme page transitions', () {
    Future<void> pushSecond(
      WidgetTester tester, {
      required TargetPlatform platform,
      required bool reduceMotion,
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: MaterialApp(
            theme: AppTheme.dark.copyWith(platform: platform),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('second')),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    Offset secondPage(WidgetTester tester) =>
        tester.getTopLeft(find.text('second'));

    test('iOS slides like iOS; Android uses predictive back', () {
      final builders = AppTheme.pageTransitions.builders;
      expect(
        builders[TargetPlatform.iOS],
        isA<CupertinoPageTransitionsBuilder>(),
      );
      expect(builders[TargetPlatform.android], isNotNull);
    });

    testWidgets('Android animates the push', (tester) async {
      await pushSecond(
        tester,
        platform: TargetPlatform.android,
        reduceMotion: false,
      );
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('Android with reduced motion shows the page at once', (
      tester,
    ) async {
      await pushSecond(
        tester,
        platform: TargetPlatform.android,
        reduceMotion: true,
      );
      expect(secondPage(tester), Offset.zero);
      final opacities = tester.widgetList<FadeTransition>(
        find.ancestor(
          of: find.text('second'),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(opacities.every((f) => f.opacity.value == 1), isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('iOS keeps its slide and the back swipe with reduced motion', (
      tester,
    ) async {
      await pushSecond(
        tester,
        platform: TargetPlatform.iOS,
        reduceMotion: true,
      );
      expect(secondPage(tester).dx, greaterThan(0));
      await tester.pumpAndSettle();

      await tester.timedDragFrom(
        const Offset(2, 300),
        const Offset(600, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
      expect(find.text('go'), findsOneWidget);
    });
  });
}
