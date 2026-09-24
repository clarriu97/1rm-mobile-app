import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void logAndPrFlows() {
  testWidgets('log a lift, beat it with a PR, survive a relaunch', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    final t = l10n(tester);

    await tapExercise(tester, 'back_squat');
    expect(find.text(t.noRecordsYet), findsOneWidget);

    // First entry: 100 × 5 → 116.7 kg. The first entry is never a PR.
    await logEntry(tester, weight: '100', reps: '5');
    expect(find.byKey(const Key('pr-celebration')), findsNothing);
    expect(find.text(weight(tester, 116.7)), findsWidgets);
    await expectOnScreen(tester, find.text(t.workingWeights));

    // Second entry: 120 × 3 → 132.0 kg beats it.
    await logEntry(tester, weight: '120', reps: '3');
    await waitFor(tester, find.byKey(const Key('pr-celebration')));
    await waitFor(tester, find.byKey(const Key('pr-celebration')), gone: true);
    await scrollTo(tester, find.text(weight(tester, 132)));
    expect(find.text(weight(tester, 132)), findsWidgets);
    await expectOnScreen(tester, find.byKey(const Key('progress-line-chart')));

    await tester.tap(find.byTooltip(t.history));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pr-badge')), findsOneWidget);

    // Back to Home the way users do it (iOS edge swipe / Android back).
    await goBack(tester);
    await goBack(tester);
    expect(find.text('1RM'), findsOneWidget);
    expect(find.text(weight(tester, 132)), findsOneWidget);

    await relaunchApp(tester);
    expect(find.text(weight(tester, 132)), findsOneWidget);
  });

  testWidgets('invalid input shows feedback and saves nothing', (tester) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    await tapExercise(tester, 'deadlift');

    await tapKey(tester, 'add-entry-button');
    await tapKey(tester, 'save-entry-button');
    expect(find.byKey(const Key('save-entry-button')), findsOneWidget);
    expect(find.text(l10n(tester).required), findsNWidgets(2));

    await tester.tap(find.byTooltip(materialL10n(tester).closeButtonTooltip));
    await tester.pumpAndSettle();
    expect(find.text(l10n(tester).noRecordsYet), findsOneWidget);
  });
}
