import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The store listings in fastlane/ must fit what App Store Connect and
/// Google Play accept, or the upload fails.
const _locales = ['en-US', 'es-ES'];

const _appStoreLimits = {
  'name.txt': 30,
  'subtitle.txt': 30,
  'promotional_text.txt': 170,
  'description.txt': 4000,
  'keywords.txt': 100,
  'release_notes.txt': 4000,
};

const _playLimits = {
  'title.txt': 30,
  'short_description.txt': 80,
  'full_description.txt': 4000,
};

const _urls = {
  'support_url.txt': 'https://1rm.larri.dev/',
  'marketing_url.txt': 'https://1rm.larri.dev/',
  'privacy_url.txt': 'https://1rm.larri.dev/privacy/',
};

String _read(String path) => File(path).readAsStringSync();

void main() {
  for (final locale in _locales) {
    group('App Store, $locale', () {
      final dir = 'fastlane/metadata/$locale';

      _appStoreLimits.forEach((file, limit) {
        test('$file is not empty, trimmed and at most $limit characters', () {
          final text = _read('$dir/$file');
          expect(text, isNotEmpty);
          expect(text, text.trim());
          expect(text.runes.length, lessThanOrEqualTo(limit));
        });
      });

      test('keywords have no spaces after commas and skip the name', () {
        final keywords = _read('$dir/keywords.txt');
        expect(keywords, isNot(contains(', ')));
        final nameWords = _read('$dir/name.txt')
            .toLowerCase()
            .split(RegExp(r'[^\p{L}\d]+', unicode: true))
            .where((w) => w.isNotEmpty)
            .toSet();
        for (final keyword in keywords.toLowerCase().split(',')) {
          expect(keyword, isNotEmpty);
          for (final word in keyword.split(' ')) {
            expect(nameWords, isNot(contains(word)), reason: keyword);
          }
        }
      });

      _urls.forEach((file, url) {
        test('$file points to $url', () {
          expect(_read('$dir/$file'), url);
        });
      });
    });

    group('Google Play, $locale', () {
      final dir = 'fastlane/metadata/android/$locale';

      _playLimits.forEach((file, limit) {
        test('$file is not empty, trimmed and at most $limit characters', () {
          final text = _read('$dir/$file');
          expect(text, isNotEmpty);
          expect(text, text.trim());
          expect(text.runes.length, lessThanOrEqualTo(limit));
        });
      });

      test('title and short description do not say "free"', () {
        for (final file in ['title.txt', 'short_description.txt']) {
          expect(
            _read('$dir/$file').toLowerCase(),
            isNot(matches(RegExp(r'\b(free|gratis)\b'))),
          );
        }
      });
    });
  }
}
