import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void unitsFlows() {
  testWidgets('switching kg → lbs converts every number and persists', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    await tapText(tester, 'Back Squat');
    await logEntry(tester, weight: '100', reps: '1');
    await goBack(tester);
    expect(find.text('100.0 kg'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle();
    await goBack(tester);

    // Home reloads the unit from preferences when Settings closes.
    await waitFor(tester, find.text('220.5 lbs'));
    await tapText(tester, 'Back Squat');
    expect(find.text('220.5 lbs'), findsWidgets);
    // Working weights round to loadable 5 lb steps.
    await expectOnScreen(tester, find.text('220 lbs'));

    await tapKey(tester, 'add-entry-button');
    expect(find.text('lbs'), findsWidgets);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await relaunchApp(tester);
    expect(find.text('220.5 lbs'), findsOneWidget);
  });
}
