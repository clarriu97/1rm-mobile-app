import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/app_language.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/language_repository.dart';
import 'package:one_rm_mobile/services/language_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders with current unit selected', (tester) async {
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: unitService,
            currentUnit: WeightUnit.kg,
            language: testLanguage(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('lbs'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    });

    testWidgets('shows checkmark on kg when kg is selected', (tester) async {
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: unitService,
            currentUnit: WeightUnit.kg,
            language: testLanguage(),
          ),
        ),
      );

      final kgTile = find.ancestor(
        of: find.text('kg'),
        matching: find.byType(InkWell),
      );
      final lbsTile = find.ancestor(
        of: find.text('lbs'),
        matching: find.byType(InkWell),
      );

      expect(
        find.descendant(
          of: kgTile,
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: lbsTile,
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping lbs switches unit', (tester) async {
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: unitService,
            currentUnit: WeightUnit.kg,
            language: testLanguage(),
          ),
        ),
      );

      await tester.tap(find.text('lbs'));
      await tester.pumpAndSettle();

      expect(await unitService.getUnit(), WeightUnit.lbs);

      final lbsTile = find.ancestor(
        of: find.text('lbs'),
        matching: find.byType(InkWell),
      );
      expect(
        find.descendant(
          of: lbsTile,
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping kg switches unit back', (tester) async {
      final unitService = UnitService.forTesting(unit: WeightUnit.lbs);

      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: unitService,
            currentUnit: WeightUnit.lbs,
            language: testLanguage(),
          ),
        ),
      );

      await tester.tap(find.text('kg'));
      await tester.pumpAndSettle();

      expect(await unitService.getUnit(), WeightUnit.kg);
    });
  });

  group('SettingsScreen — language', () {
    Future<LanguageRepository> pump(
      WidgetTester tester, {
      AppLanguage initial = AppLanguage.system,
    }) async {
      final language = LanguageRepository(
        LanguageService.forTesting(language: initial),
        language: initial,
      );
      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: UnitService.forTesting(),
            currentUnit: WeightUnit.kg,
            language: language,
          ),
        ),
      );
      return language;
    }

    Finder check(String key) => find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byIcon(Icons.check_circle_rounded),
    );

    testWidgets('offers the device language, English and Spanish', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Same as device'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(check('language-system'), findsOneWidget);
      expect(check('language-en'), findsNothing);
      expect(check('language-es'), findsNothing);
    });

    testWidgets('marks the saved choice', (tester) async {
      await pump(tester, initial: AppLanguage.es);

      expect(check('language-es'), findsOneWidget);
      expect(check('language-system'), findsNothing);
    });

    testWidgets('tapping a language saves it and moves the mark', (
      tester,
    ) async {
      final language = await pump(tester);

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(language.language, AppLanguage.es);
      expect(check('language-es'), findsOneWidget);
      expect(check('language-system'), findsNothing);
    });

    testWidgets('choosing a language keeps the unit untouched', (tester) async {
      final units = UnitService.forTesting(unit: WeightUnit.lbs);
      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: units,
            currentUnit: WeightUnit.lbs,
            language: testLanguage(),
          ),
        ),
      );

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(await units.getUnit(), WeightUnit.lbs);
    });
  });
  group('SettingsScreen — screen reader', () {
    testWidgets('sections are headers; choices say which is selected', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestApp(
          SettingsScreen(
            unitService: UnitService.forTesting(),
            currentUnit: WeightUnit.kg,
            language: testLanguage(),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Units')),
        isSemantics(isHeader: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Language')),
        isSemantics(isHeader: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('kg')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('lbs')),
        isSemantics(isButton: true, isSelected: false),
      );
      semantics.dispose();
    });
  });
}
