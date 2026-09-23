import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/ui/widgets/pr_celebration.dart';

import '../../helpers/test_app.dart';

void main() {
  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> open(WidgetTester tester, {bool reduceMotion = false}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: buildTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showPrCelebration(
                context,
                exerciseName: 'Back Squat',
                oneRM: 160,
                previousBest: 155,
                unit: WeightUnit.kg,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
  }

  testWidgets('shows the new best, the gain and fires a heavy haptic', (
    tester,
  ) async {
    await open(tester);
    await tester.pumpAndSettle();

    expect(find.text('NEW PR'), findsOneWidget);
    expect(find.text('BACK SQUAT'), findsOneWidget);
    expect(find.text('160.0 kg'), findsOneWidget);
    expect(find.text('+5.0 kg over your previous best'), findsOneWidget);
    expect(
      platformCalls.any(
        (c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.heavyImpact',
      ),
      isTrue,
    );

    await tester.pump(kPrCelebrationDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('closes itself after the display duration', (tester) async {
    await open(tester);
    await tester.pumpAndSettle();

    await tester.pump(
      kPrCelebrationDuration - const Duration(milliseconds: 100),
    );
    expect(find.byKey(const Key('pr-celebration')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pr-celebration')), findsNothing);
  });

  testWidgets('tapping closes it early and cancels the timer', (tester) async {
    await open(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pr-celebration')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pr-celebration')), findsNothing);

    // The pending auto-close must not pop the page underneath.
    await tester.pump(kPrCelebrationDuration);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('appears immediately without animation when motion is reduced', (
    tester,
  ) async {
    await open(tester, reduceMotion: true);
    await tester.pump();

    expect(find.byKey(const Key('pr-celebration')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('pr-celebration')),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );

    await tester.pump(kPrCelebrationDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('announces itself to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('New personal record: Back Squat, 160.0 kg'),
      findsOneWidget,
    );

    await tester.pump(kPrCelebrationDuration);
    await tester.pumpAndSettle();
    handle.dispose();
  });
}
