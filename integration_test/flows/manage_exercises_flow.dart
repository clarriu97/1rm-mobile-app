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

    await typeInto(
      tester,
      'exercise-search',
      exerciseName(tester, 'back_squat'),
    );
    await tapKey(tester, 'toggle-back_squat');

    await typeInto(tester, 'exercise-search', '');
    await tapKey(tester, 'new-exercise-button');
    await tester.enterText(
      find.byKey(const Key('new-exercise-name')),
      'Zercher Squat',
    );
    await tapKey(tester, 'create-exercise-button');

    await goBack(tester);
    expect(find.text(exerciseName(tester, 'back_squat')), findsNothing);
    await tapExercise(tester, 'thruster');
    await goBack(tester);
    await tapText(tester, 'Zercher Squat');
    await logEntry(tester, weight: '100', reps: '1');
    expect(find.text(weight(tester, 100)), findsWidgets);
    await goBack(tester);

    await relaunchApp(tester);
    expect(find.text(exerciseName(tester, 'back_squat')), findsNothing);
    await tapText(tester, 'Zercher Squat');
    expect(find.text(weight(tester, 100)), findsWidgets);
  });

  testWidgets('rename a custom exercise, delete it with undo, then for good', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);

    await tapKey(tester, 'manage-exercises-button');
    await tapKey(tester, 'new-exercise-button');
    await tester.enterText(
      find.byKey(const Key('new-exercise-name')),
      'Zercer Squat',
    );
    await tapKey(tester, 'create-exercise-button');

    final edit = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('edit-custom_'),
    );
    await scrollTo(tester, edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-exercise-name')),
      'Zercher Squat',
    );
    await tapKey(tester, 'save-exercise-button');
    await goBack(tester);

    await tapText(tester, 'Zercher Squat');
    await logEntry(tester, weight: '100', reps: '1');
    await goBack(tester);

    // Delete it with its entry, then undo.
    await tapKey(tester, 'manage-exercises-button');
    await scrollTo(tester, edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tapKey(tester, 'delete-exercise-button');
    await waitFor(tester, find.byKey(const Key('undo-button')));
    expect(find.text('Zercher Squat'), findsNothing);
    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pumpAndSettle();
    await goBack(tester);

    await relaunchApp(tester);
    await tapText(tester, 'Zercher Squat');
    expect(find.text(weight(tester, 100)), findsWidgets);
    await goBack(tester);

    // Delete for good.
    await tapKey(tester, 'manage-exercises-button');
    await scrollTo(tester, edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tapKey(tester, 'delete-exercise-button');
    await waitFor(tester, find.byKey(const Key('undo-button')));
    await goBack(tester);
    expect(find.text('Zercher Squat'), findsNothing);

    await relaunchApp(tester);
    await tapKey(tester, 'manage-exercises-button');
    await typeInto(tester, 'exercise-search', 'Zercher');
    expect(edit, findsNothing);
    expect(find.text(l10n(tester).noExercisesMatch('Zercher')), findsOneWidget);
  });
}
