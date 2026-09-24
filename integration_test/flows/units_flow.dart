import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';

import '../helpers.dart';

void unitsFlows() {
  testWidgets('switching kg → lbs converts every number and persists', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    await tapExercise(tester, 'back_squat');
    await logEntry(tester, weight: '100', reps: '1');
    await goBack(tester);
    expect(find.text(weight(tester, 100)), findsOneWidget);

    await tester.tap(find.byTooltip(l10n(tester).settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle();
    await goBack(tester);

    // Home reloads the unit from preferences when Settings closes.
    final inLbs = find.text(weight(tester, 220.5, unit: WeightUnit.lbs));
    await waitFor(tester, inLbs);
    await tapExercise(tester, 'back_squat');
    expect(inLbs, findsWidgets);
    // Working weights round to loadable 5 lb steps.
    await expectOnScreen(
      tester,
      find.text(weight(tester, 220, unit: WeightUnit.lbs, decimals: 0)),
    );

    await tapKey(tester, 'add-entry-button');
    expect(find.text('lbs'), findsWidgets);
    await tester.tap(find.byTooltip(materialL10n(tester).closeButtonTooltip));
    await tester.pumpAndSettle();

    await relaunchApp(tester);
    expect(inLbs, findsOneWidget);
  });
}
