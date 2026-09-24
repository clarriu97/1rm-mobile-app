import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders first page with title and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('What is 1RM?'), findsOneWidget);
      expect(find.textContaining('One-Rep Max'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
      expect(find.textContaining('Epley formula'), findsOneWidget);
    });

    testWidgets('navigates to third page on second Next tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Train smarter'), findsOneWidget);
      expect(find.textContaining('working weights'), findsOneWidget);
    });

    testWidgets('shows Get Started on last page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('hides Skip button on last page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      final skip = tester.widget<Visibility>(
        find.ancestor(of: find.text('Skip'), matching: find.byType(Visibility)),
      );
      expect(skip.visible, isFalse);
      expect(find.text('Skip').hitTestable(), findsNothing);
    });

    testWidgets('calls onComplete when Get Started is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('calls onComplete when Skip is tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) => completed = true)),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('swipe navigates to next page', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Log your lifts'), findsOneWidget);
    });

    testWidgets('renders 4 page indicators', (tester) async {
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('each page shows its own illustration', (tester) async {
      Finder illustration(String name) => find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            (w.bytesLoader as SvgAssetLoader).assetName ==
                'assets/illustrations/$name.svg',
      );

      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );
      expect(illustration('onboarding_max'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      expect(illustration('onboarding_log'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
      expect(illustration('onboarding_table'), findsOneWidget);
    });
  });

  group('defaultUnitForCountry', () {
    test('pounds for countries that do not use the metric system', () {
      for (final code in ['US', 'us', 'LR', 'MM']) {
        expect(defaultUnitForCountry(code), WeightUnit.lbs, reason: code);
      }
    });

    test('kilograms everywhere else and when unknown', () {
      for (final code in ['ES', 'GB', 'MX', 'CA', '', null]) {
        expect(defaultUnitForCountry(code), WeightUnit.kg, reason: '$code');
      }
    });
  });

  Future<void> next(WidgetTester tester, [int times = 1]) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pumpAndSettle();
    }
  }

  bool isSelected(WidgetTester tester, Key key) => tester
      .widget<Semantics>(
        find
            .ancestor(of: find.byKey(key), matching: find.byType(Semantics))
            .first,
      )
      .properties
      .selected!;

  group('OnboardingScreen — unit choice', () {
    testWidgets('unit page preselects the initial unit', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          OnboardingScreen(onComplete: (_) {}, initialUnit: WeightUnit.lbs),
        ),
      );
      await next(tester, 2);

      expect(find.text('KG'), findsOneWidget);
      expect(find.text('LBS'), findsOneWidget);
      expect(isSelected(tester, const Key('unit-option-lbs')), isTrue);
      expect(isSelected(tester, const Key('unit-option-kg')), isFalse);
    });

    testWidgets('the chosen unit is reported when finishing', (tester) async {
      OnboardingChoices? choices;
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (c) => choices = c)),
      );
      await next(tester, 2);

      await tester.tap(find.byKey(const Key('unit-option-lbs')));
      await tester.pump();
      expect(isSelected(tester, const Key('unit-option-lbs')), isTrue);

      await next(tester, 2);
      expect(choices!.unit, WeightUnit.lbs);
    });

    testWidgets('skipping keeps the initial unit and the default lifts', (
      tester,
    ) async {
      OnboardingChoices? choices;
      await tester.pumpWidget(
        buildTestApp(
          OnboardingScreen(
            onComplete: (c) => choices = c,
            initialUnit: WeightUnit.lbs,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('onboarding-skip-button')));
      await tester.pump();
      expect(choices!.unit, WeightUnit.lbs);
      expect(choices!.lifts, isNull);
    });
  });

  group('OnboardingScreen — pick your lifts', () {
    final defaults = Set<String>.unmodifiable({
      for (final e in defaultExercises)
        if (e.defaultVisible) e.id,
    });

    Future<OnboardingChoices? Function()> openPicker(
      WidgetTester tester, {
      Set<String>? initialLifts,
    }) async {
      OnboardingChoices? choices;
      await tester.pumpWidget(
        buildTestApp(
          OnboardingScreen(
            onComplete: (c) => choices = c,
            initialLifts: initialLifts,
          ),
        ),
      );
      await next(tester, 3);
      return () => choices;
    }

    Future<void> tapChip(WidgetTester tester, String id) async {
      final chip = find.byKey(Key('lift-chip-$id'));
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('pick-lifts-page')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(chip);
      await tester.pump();
    }

    testWidgets('lists families with the core lifts preselected', (
      tester,
    ) async {
      await openPicker(tester);

      expect(find.text('Pick your lifts'), findsOneWidget);
      expect(find.text('SQUAT'), findsOneWidget);
      expect(find.text('${defaults.length} selected'), findsOneWidget);
      expect(isSelected(tester, const Key('lift-chip-back_squat')), isTrue);
      expect(isSelected(tester, const Key('lift-chip-box_squat')), isFalse);
      expect(find.textContaining('Manage exercises'), findsOneWidget);
    });

    testWidgets('toggling lifts is reflected in the result', (tester) async {
      final result = await openPicker(tester);

      await tapChip(tester, 'thruster');
      await tapChip(tester, 'snatch');

      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pump();

      expect(result()!.lifts, {
        ...defaults.where((id) => id != 'snatch'),
        'thruster',
      });
    });

    testWidgets('the counter follows the selection', (tester) async {
      tester.view.physicalSize = const Size(430, 1400) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await openPicker(tester);

      await tester.tap(find.byKey(const Key('lift-chip-box_squat')));
      await tester.pump();
      expect(find.text('${defaults.length + 1} selected'), findsOneWidget);

      await tester.tap(find.byKey(const Key('lift-chip-box_squat')));
      await tester.pump();
      expect(find.text('${defaults.length} selected'), findsOneWidget);
    });

    testWidgets('with no lifts selected the button is disabled', (
      tester,
    ) async {
      final result = await openPicker(tester, initialLifts: {'back_squat'});

      await tapChip(tester, 'back_squat');

      expect(find.text('Pick at least one lift'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('onboarding-next-button')),
      );
      expect(button.onPressed, isNull);
      expect(result(), isNull);
    });

    testWidgets('initial lifts override the defaults', (tester) async {
      final result = await openPicker(tester, initialLifts: {'hip_thrust'});

      expect(find.text('1 selected'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onboarding-next-button')));
      await tester.pump();
      expect(result()!.lifts, {'hip_thrust'});
    });
  });
  group('OnboardingScreen — lift chips contrast', () {
    for (final locale in const [Locale('en'), Locale('es')]) {
      testWidgets('selected and unselected chips meet AA ($locale)', (
        tester,
      ) async {
        // Tall enough that no chip sits under the list's fading bottom edge,
        // which the layout matrix can't avoid on real screen sizes.
        tester.view
          ..physicalSize = const Size(1000, 3000)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          buildTestApp(OnboardingScreen(onComplete: (_) {}), locale: locale),
        );
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.byKey(const Key('onboarding-next-button')));
          await tester.pumpAndSettle();
        }
        final list = tester.state<ScrollableState>(
          find.descendant(
            of: find.byKey(const Key('pick-lifts-page')),
            matching: find.byType(Scrollable),
          ),
        );
        expect(list.position.maxScrollExtent, 0, reason: 'everything fits');

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  });
  group('OnboardingScreen — screen reader', () {
    testWidgets('page titles are headers; illustrations are decoration', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestApp(OnboardingScreen(onComplete: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('What is 1RM?')),
        isSemantics(isHeader: true),
      );
      expect(
        find.bySemanticsLabel(RegExp('image', caseSensitive: false)),
        findsNothing,
      );
      semantics.dispose();
    });
  });
}
