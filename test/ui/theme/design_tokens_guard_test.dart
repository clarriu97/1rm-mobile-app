import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screens must take colors and text styles from the theme (see AGENTS.md).
void main() {
  final screens = Directory('lib/ui')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('/theme/'))
      .toList();

  test('there are screens to check', () {
    expect(screens, isNotEmpty);
  });

  for (final file in screens) {
    test('${file.path} uses no literal colors or text styles', () {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('Color(0x')));
      expect(source, isNot(contains('TextStyle(')));
      expect(source, isNot(contains('Colors.white')));
      expect(source, isNot(contains('Colors.black')));
    });
  }
}
