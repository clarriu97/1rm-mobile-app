import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/undo_snack_bar.dart';

import '../helpers/devices.dart';
import '../helpers/test_app.dart';

void main() {
  group('showUndoSnackBar', () {
    Future<void> show(
      WidgetTester tester,
      String message,
      VoidCallback onUndo, {
      Locale? locale,
    }) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showUndoSnackBar(context, message: message, onUndo: onUndo),
                child: const Text('go'),
              ),
            ),
          ),
          locale: locale,
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the message; Undo runs the callback and closes it', (
      tester,
    ) async {
      var undone = 0;
      await show(tester, 'Deleted 100.0 kg × 5 reps', () => undone++);

      expect(find.text('Deleted 100.0 kg × 5 reps'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(undone, 1);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('stays until the user acts, like a SnackBar with an action', (
      tester,
    ) async {
      await show(tester, 'Deleted', () {});
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('a new one replaces the one on screen', (tester) async {
      await show(tester, 'first', () {});
      await tester.tap(find.text('go'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('fits the narrowest phone at 200 % text in Spanish', (
      tester,
    ) async {
      testDevices.first.apply(tester, textScale: 2);
      await show(
        tester,
        'Borrado: ${'W' * 40} y 12 registros',
        () {},
        locale: const Locale('es'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Deshacer'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('undo-button'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
