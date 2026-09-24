import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';

import '../helpers.dart';

void onboardingFlows() {
  testWidgets('first run: the unit and lifts picked in onboarding stick', (
    tester,
  ) async {
    await launchApp(tester);
    final welcome = find.text(l10n(tester).onboardingWhatTitle);
    expect(welcome, findsOneWidget);

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
    await tapExercise(tester, 'thruster');
    await logEntry(tester, weight: '95', reps: '1');
    final logged = find.text(weight(tester, 95, unit: WeightUnit.lbs));
    expect(logged, findsWidgets);

    await relaunchApp(tester);

    expect(welcome, findsNothing);
    await tapExercise(tester, 'thruster');
    expect(logged, findsWidgets);
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
    final welcome = find.text(l10n(tester).onboardingWhatTitle);
    await tapKey(tester, 'onboarding-skip-button');

    await waitFor(tester, find.text('1RM'));
    expect(find.text(exerciseName(tester, 'back_squat')), findsOneWidget);

    await relaunchApp(tester);
    expect(welcome, findsNothing);
  });
}
