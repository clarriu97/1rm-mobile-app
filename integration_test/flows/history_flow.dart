import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void historyFlows() {
  testWidgets('edit an entry, delete with swipe and undo, delete for good', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    final t = l10n(tester);
    await tapExercise(tester, 'bench_press');
    await logEntry(tester, weight: '80', reps: '5');
    await waitFor(tester, find.byKey(const Key('pr-celebration')), gone: true);

    await tester.tap(find.byTooltip(t.history));
    await tester.pumpAndSettle();

    // Edit 80 × 5 into 80 × 8.
    await tester.tap(find.text(t.set(weight(tester, 80), 5)));
    await tester.pumpAndSettle();
    expect(find.text(t.editEntry), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '8');
    await tapKey(tester, 'save-entry-button');
    expect(find.text(t.set(weight(tester, 80), 8)), findsOneWidget);
    expect(find.text(t.oneRmValue(weight(tester, 101.3))), findsOneWidget);

    // Swipe to delete, then undo.
    await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text(t.noRecordsYet), findsOneWidget);
    // The Undo snackbar appears once the delete is on disk.
    await waitFor(tester, find.text(t.undo));
    await tester.tap(find.text(t.undo));
    await tester.pumpAndSettle();
    expect(find.text(t.set(weight(tester, 80), 8)), findsOneWidget);

    await relaunchApp(tester);
    await tapExercise(tester, 'bench_press');
    expect(find.text(weight(tester, 101.3)), findsWidgets);

    // Delete for good with the button.
    await tester.tap(find.byTooltip(t.history));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(materialL10n(tester).deleteButtonTooltip));
    await tester.pumpAndSettle();
    expect(find.text(t.noRecordsYet), findsOneWidget);

    await relaunchApp(tester);
    await tapExercise(tester, 'bench_press');
    expect(find.text(t.noRecordsYet), findsOneWidget);
  });
}
