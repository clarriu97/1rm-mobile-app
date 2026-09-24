import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/services/link_service.dart';

void main() {
  group('LinkService.forTesting', () {
    test('records what it was asked to open and succeeds by default', () async {
      final links = LinkService.forTesting();
      final url = Uri.https('1rm.larri.dev', '/');

      expect(await links.open(url), isTrue);
      expect(links.opened, [url]);
    });

    test('can fail like a device with nothing to open the link', () async {
      final links = LinkService.forTesting(succeeds: false);
      expect(await links.open(Uri.parse('mailto:a@b.c')), isFalse);
    });
  });
}
