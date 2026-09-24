import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/l10n/app_localizations.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> _messages(String locale) => {
  for (final MapEntry(:key, :value) in _arb(locale).entries)
    if (!key.startsWith('@')) key: value as String,
};

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet();

/// Characters the font can draw, from its Unicode BMP `cmap` subtable
/// (platform 3, encoding 1, format 4).
Set<int> _fontCharacters(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  final tableCount = data.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < tableCount; i++) {
    final record = 12 + i * 16;
    if (String.fromCharCodes(data.buffer.asUint8List(record, 4)) == 'cmap') {
      cmap = data.getUint32(record + 8);
    }
  }
  expect(cmap, isNot(-1), reason: '$path has no cmap table');
  var subtable = -1;
  for (var i = 0; i < data.getUint16(cmap + 2); i++) {
    final record = cmap + 4 + i * 8;
    if (data.getUint16(record) == 3 && data.getUint16(record + 2) == 1) {
      subtable = cmap + data.getUint32(record + 4);
    }
  }
  expect(subtable, isNot(-1), reason: '$path has no Unicode BMP cmap');
  expect(data.getUint16(subtable), 4);
  final segments = data.getUint16(subtable + 6) ~/ 2;
  final ends = subtable + 14;
  final starts = ends + segments * 2 + 2;
  final deltas = starts + segments * 2;
  final rangeOffsets = deltas + segments * 2;
  final characters = <int>{};
  for (var s = 0; s < segments; s++) {
    final start = data.getUint16(starts + s * 2);
    final end = data.getUint16(ends + s * 2);
    final delta = data.getUint16(deltas + s * 2);
    final rangeOffset = data.getUint16(rangeOffsets + s * 2);
    for (var c = start; c <= end && c != 0xFFFF; c++) {
      var glyph = 0;
      if (rangeOffset == 0) {
        glyph = (c + delta) & 0xFFFF;
      } else {
        final index = data.getUint16(
          rangeOffsets + s * 2 + rangeOffset + (c - start) * 2,
        );
        if (index != 0) glyph = (index + delta) & 0xFFFF;
      }
      if (glyph != 0) characters.add(c);
    }
  }
  return characters;
}

void main() {
  final en = _messages('en');
  final es = _messages('es');

  group('translations', () {
    test('every English message is translated to Spanish and vice versa', () {
      expect(es.keys.toSet(), en.keys.toSet());
    });

    test('translations use the same placeholders as the English message', () {
      for (final key in en.keys) {
        expect(_placeholders(es[key]!), _placeholders(en[key]!), reason: key);
      }
    });

    test('no message is empty', () {
      for (final MapEntry<String, String>(:key, :value) in [
        ...en.entries,
        ...es.entries,
      ]) {
        expect(value.trim(), isNotEmpty, reason: key);
      }
    });

    test('the app supports exactly the languages it has translations for', () {
      final arbLocales = Directory('lib/l10n')
          .listSync()
          .map((f) => RegExp(r'app_(\w+)\.arb$').firstMatch(f.path)?.group(1))
          .nonNulls
          .toSet();
      expect(
        AppLocalizations.supportedLocales.map((l) => l.toLanguageTag()).toSet(),
        arbLocales,
      );
    });

    test('iOS declares every supported language', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final declared = RegExp(
        r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
        dotAll: true,
      ).firstMatch(plist);
      expect(declared, isNotNull);
      expect(
        RegExp(
          r'<string>(\w+)</string>',
        ).allMatches(declared!.group(1)!).map((m) => m.group(1)).toSet(),
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      );
    });
  });

  group('fonts draw every character of every message', () {
    final fonts = [
      ...Directory('assets/fonts').listSync().map((f) => f.path),
    ].where((p) => p.endsWith('.ttf')).toList()..sort();

    test('the app bundles the fonts being checked', () {
      expect(fonts, hasLength(5));
    });

    for (final font in fonts) {
      test(font.split('/').last, () {
        final drawable = _fontCharacters(font);
        for (final MapEntry<String, String>(:key, :value) in [
          ...en.entries,
          ...es.entries,
        ]) {
          // Labels and headers are shown uppercase too.
          final missing = '$value${value.toUpperCase()}'.runes
              .where((c) => c != 0x0A && !drawable.contains(c))
              .map(String.fromCharCode)
              .toSet();
          expect(missing, isEmpty, reason: '$key: "$value"');
        }
      });
    }

    test('the check catches a character the fonts lack', () {
      final barlow = _fontCharacters('assets/fonts/Barlow-Regular.ttf');
      expect(barlow, contains('ñ'.runes.single));
      expect(barlow, isNot(contains('→'.runes.single)));
    });
  });
}
