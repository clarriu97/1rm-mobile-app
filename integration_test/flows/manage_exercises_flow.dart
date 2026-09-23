import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void manageExercisesFlows() {
  testWidgets('hide, show and create exercises; Home follows', (tester) async {
    await launchApp(tester);
    await completeOnboarding(tester);

    await tapKey(tester, 'manage-exercises-button');

    await typeInto(tester, 'exercise-search', 'thru');
    await tapKey(tester, 'toggle-thruster');

    await typeInto(tester, 'exercise-search', 'back squat');
    await tapKey(tester, 'toggle-back_squat');

    await typeInto(tester, 'exercise-search', '');
    await tapKey(tester, 'new-exercise-button');
    await tester.enterText(
      find.byKey(const Key('new-exercise-name')),
      'Zercher Squat',
    );
    await tapKey(tester, 'create-exercise-button');

    await goBack(tester);
    expect(find.text('Back Squat'), findsNothing);
    await tapText(tester, 'Thruster');
    await goBack(tester);
    await tapText(tester, 'Zercher Squat');
    await logEntry(tester, weight: '100', reps: '1');
    expect(find.text('100.0 kg'), findsWidgets);
    await goBack(tester);

    await relaunchApp(tester);
    expect(find.text('Back Squat'), findsNothing);
    await tapText(tester, 'Zercher Squat');
    expect(find.text('100.0 kg'), findsWidgets);
  });
}
