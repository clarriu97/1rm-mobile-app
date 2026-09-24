import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/app_info.dart';
import 'package:one_rm_mobile/services/link_service.dart';
import 'package:one_rm_mobile/ui/about_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<FakeLinkService> pump(
    WidgetTester tester, {
    bool linksWork = true,
    Locale? locale,
  }) async {
    final links = LinkService.forTesting(succeeds: linksWork);
    await tester.pumpWidget(
      buildTestApp(AboutScreen(links: links), locale: locale),
    );
    return links;
  }

  Future<void> tapTile(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('AboutScreen', () {
    testWidgets('shows the version and that data stays on the phone', (
      tester,
    ) async {
      await pump(tester);

      expect(
        find.text('Version $appVersion ($appBuildNumber)'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Everything you log stays on this phone. No accounts, no tracking.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('each link opens where it says', (tester) async {
      final links = await pump(tester);

      await tapTile(tester, 'about-website');
      await tapTile(tester, 'about-privacy');
      await tapTile(tester, 'about-terms');
      await tapTile(tester, 'about-contact');

      expect(links.opened, [
        Uri.parse('https://1rm.larri.dev/'),
        Uri.parse('https://1rm.larri.dev/privacy/'),
        Uri.parse('https://1rm.larri.dev/terms/'),
        Uri.parse('mailto:info.1rm@larri.dev'),
      ]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a link nothing can open says so', (tester) async {
      await pump(tester, linksWork: false);

      await tapTile(tester, 'about-contact');

      expect(find.text('Could not open info.1rm@larri.dev.'), findsOneWidget);
    });

    testWidgets('licenses open the standard license page with the version', (
      tester,
    ) async {
      await pump(tester);

      await tapTile(tester, 'about-licenses');

      expect(find.byType(LicensePage), findsOneWidget);
      expect(find.text('Version $appVersion ($appBuildNumber)'), findsWidgets);
    });

    testWidgets('outside links are announced as links', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(
        tester.getSemantics(find.byKey(const Key('about-privacy'))),
        isSemantics(isLink: true),
      );
      semantics.dispose();
    });

    testWidgets('in Spanish', (tester) async {
      await pump(tester, locale: const Locale('es'));

      expect(find.text('Acerca de'), findsOneWidget);
      expect(
        find.text('Versión $appVersion ($appBuildNumber)'),
        findsOneWidget,
      );
      expect(find.text('Política de privacidad'), findsOneWidget);
    });
  });
}
