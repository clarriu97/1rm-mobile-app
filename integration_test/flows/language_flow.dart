import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void languageFlows() {
  testWidgets('pick a language in Settings; it survives a relaunch and '
      'can go back to the device language', (tester) async {
    await launchApp(tester);
    await completeOnboarding(tester);

    await tester.tap(find.byTooltip(l10n(tester).settings));
    await tester.pumpAndSettle();
    await tapKey(tester, 'language-es');
    expect(find.text('Ajustes'), findsOneWidget);
    await goBack(tester);
    expect(find.text('Sentadilla trasera'), findsOneWidget);

    await relaunchApp(tester);
    expect(find.text('Sentadilla trasera'), findsOneWidget);

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'language-en');
    expect(find.text('Settings'), findsOneWidget);
    await goBack(tester);
    expect(find.text('Back Squat'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'language-system');
    await goBack(tester);
    final device = PlatformDispatcher.instance.locale.languageCode;
    expect(l10n(tester).localeName, device == 'es' ? 'es' : 'en');
    expect(find.text(exerciseName(tester, 'back_squat')), findsOneWidget);
  });
}
