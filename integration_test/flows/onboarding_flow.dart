import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void onboardingFlows() {
  testWidgets('first run: the unit and lifts picked in onboarding stick', (
    tester,
  ) async {
    await launchApp(tester);
    expect(find.text('What is 1RM?'), findsOneWidget);

    await tapKey(tester, 'onboarding-next-button');
    await tapKey(tester, 'onboarding-next-button');
    await tapKey(tester, 'unit-option-lbs');
    await tapKey(tester, 'onboarding-next-button');

    // Pick your lifts: drop Snatch, add Thruster.
    expect(find.byKey(const Key('pick-lifts-page')), findsOneWidget);
    await tapKey(tester, 'lift-chip-snatch');
    await tapKey(tester, 'lift-chip-thruster');
    await tapKey(tester, 'onboarding-next-button');

    await waitFor(tester, find.text('1RM'));
    await tapText(tester, 'Thruster');
    await logEntry(tester, weight: '95', reps: '1');
    expect(find.text('95.0 lbs'), findsWidgets);

    await relaunchApp(tester);

    expect(find.text('What is 1RM?'), findsNothing);
    await tapText(tester, 'Thruster');
    expect(find.text('95.0 lbs'), findsWidgets);
    await goBack(tester);

    await tapKey(tester, 'manage-exercises-button');
    await typeInto(tester, 'exercise-search', 'snatch');
    final snatch = tester.widget<SwitchListTile>(
      find.byKey(const Key('toggle-snatch')),
    );
    expect(snatch.value, isFalse);
  });

  testWidgets('skipping onboarding lands on Home with the default lifts', (
    tester,
  ) async {
    await launchApp(tester);
    await tapKey(tester, 'onboarding-skip-button');

    await waitFor(tester, find.text('1RM'));
    expect(find.text('Back Squat'), findsOneWidget);

    await relaunchApp(tester);
    expect(find.text('What is 1RM?'), findsNothing);
  });
}
