import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/app_info.dart';

import '../helpers.dart';

void aboutFlows() {
  testWidgets('Settings → About shows the version and the licenses', (
    tester,
  ) async {
    await launchApp(tester);
    await completeOnboarding(tester);

    await tester.tap(find.byTooltip(l10n(tester).settings));
    await tester.pumpAndSettle();
    await tapKey(tester, 'about-button');
    expect(
      find.text(l10n(tester).version(appVersion, appBuildNumber)),
      findsOneWidget,
    );

    await tapKey(tester, 'about-licenses');
    expect(find.byType(LicensePage), findsOneWidget);
    await goBack(tester);
    await goBack(tester);
    await goBack(tester);
    expect(find.text('1RM'), findsOneWidget);
  });
}
