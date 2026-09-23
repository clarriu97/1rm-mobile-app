import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void logAndPrFlows() {
  testWidgets('log a lift, beat it with a PR, survive a relaunch', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);

    await tapText(tester, 'Back Squat');
    expect(find.text('No records yet'), findsOneWidget);

    // First entry: 100 × 5 → 116.7 kg. The first entry is never a PR.
    await logEntry(tester, weight: '100', reps: '5');
    expect(find.byKey(const Key('pr-celebration')), findsNothing);
    expect(find.text('116.7 kg'), findsWidgets);
    await expectOnScreen(tester, find.text('Working weights'));

    // Second entry: 120 × 3 → 132.0 kg beats it.
    await logEntry(tester, weight: '120', reps: '3');
    await waitFor(tester, find.byKey(const Key('pr-celebration')));
    await waitFor(tester, find.byKey(const Key('pr-celebration')), gone: true);
    await scrollTo(tester, find.text('132.0 kg'));
    expect(find.text('132.0 kg'), findsWidgets);
    await expectOnScreen(tester, find.byKey(const Key('progress-line-chart')));

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pr-badge')), findsOneWidget);

    // Back to Home the way users do it (iOS edge swipe / Android back).
    await goBack(tester);
    await goBack(tester);
    expect(find.text('1RM'), findsOneWidget);
    expect(find.text('132.0 kg'), findsOneWidget);

    await relaunchApp(tester);
    expect(find.text('132.0 kg'), findsOneWidget);
  });

  testWidgets('invalid input shows feedback and saves nothing', (tester) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    await tapText(tester, 'Deadlift');

    await tapKey(tester, 'add-entry-button');
    await tapKey(tester, 'save-entry-button');
    expect(find.byKey(const Key('save-entry-button')), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('No records yet'), findsOneWidget);
  });
}
