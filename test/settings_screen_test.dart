import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/app_theme.dart';
import 'package:one_rm_mobile/ui/settings_screen.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(theme: AppTheme.dark, home: home);
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders with current unit selected', (tester) async {
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        _buildApp(
          SettingsScreen(unitService: unitService, currentUnit: WeightUnit.kg),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('lbs'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows checkmark on kg when kg is selected', (tester) async {
      final unitService = UnitService.forTesting();

      await tester.pumpWidget(
        _buildApp(
          SettingsScreen(unitService: unitService, currentUnit: WeightUnit.kg),
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
        _buildApp(
          SettingsScreen(unitService: unitService, currentUnit: WeightUnit.kg),
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
        _buildApp(
          SettingsScreen(unitService: unitService, currentUnit: WeightUnit.lbs),
        ),
      );

      await tester.tap(find.text('kg'));
      await tester.pumpAndSettle();

      expect(await unitService.getUnit(), WeightUnit.kg);
    });
  });
}
