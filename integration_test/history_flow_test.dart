import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  setUpE2E();

  testWidgets('edit an entry, delete with swipe and undo, delete for good', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);
    await tapText(tester, 'Bench Press');
    await logEntry(tester, weight: '80', reps: '5');
    await pumpUntil(
      tester,
      find.byKey(const Key('pr-celebration')),
      gone: true,
    );

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    // Edit 80 × 5 into 80 × 8.
    await tester.tap(find.text('80.0 kg × 5 reps'));
    await tester.pumpAndSettle();
    expect(find.text('EDIT ENTRY'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '8');
    await tapKey(tester, 'save-entry-button');
    expect(find.text('80.0 kg × 8 reps'), findsOneWidget);
    expect(find.text('1RM: 101.3 kg'), findsOneWidget);

    // Swipe to delete, then undo.
    await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('No records yet'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('80.0 kg × 8 reps'), findsOneWidget);

    await relaunchApp(tester);
    await tapText(tester, 'Bench Press');
    expect(find.text('101.3 kg'), findsWidgets);

    // Delete for good with the button.
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No records yet'), findsOneWidget);

    await relaunchApp(tester);
    await tapText(tester, 'Bench Press');
    expect(find.text('No records yet'), findsOneWidget);
  });
}
