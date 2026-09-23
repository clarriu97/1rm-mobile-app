import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/font_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers the OFL license of every bundled font', () async {
    registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((e) => e.packages).toSet();
    expect(packages, containsAll(['Big Shoulders Display', 'Barlow']));

    final barlow = entries.firstWhere((e) => e.packages.contains('Barlow'));
    final text = barlow.paragraphs.map((p) => p.text).join(' ');
    expect(text, contains('SIL Open Font License'));
  });
}
