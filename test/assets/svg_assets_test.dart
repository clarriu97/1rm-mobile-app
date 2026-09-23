import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/ui/theme/app_colors.dart';

List<File> _svgs(String dir) =>
    Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

final _hexColor = RegExp('#[0-9A-Fa-f]{6}');

void main() {
  final icons = _svgs('assets/icons');
  final illustrations = _svgs('assets/illustrations');

  test('asset folders are not empty', () {
    expect(icons, isNotEmpty);
    expect(illustrations, isNotEmpty);
  });

  test('every default exercise points to an existing icon', () {
    for (final exercise in defaultExercises) {
      expect(
        File(exercise.assetPath).existsSync(),
        isTrue,
        reason: '${exercise.id} → ${exercise.assetPath}',
      );
    }
  });

  group('exercise icons', () {
    for (final file in icons) {
      final name = file.uri.pathSegments.last;
      final source = file.readAsStringSync();

      test('$name is on the 48×48 grid', () {
        expect(source, contains('viewBox="0 0 48 48"'));
      });

      test('$name is tintable (currentColor only)', () {
        expect(source, contains('currentColor'));
        expect(_hexColor.hasMatch(source), isFalse);
      });
    }
  });

  group('illustrations', () {
    final palette = {
      _hex(AppColors.accent),
      _hex(AppColors.textPrimary),
      _hex(AppColors.background),
    };

    for (final file in illustrations) {
      final name = file.uri.pathSegments.last;
      final source = file.readAsStringSync();

      test('$name only uses palette colors', () {
        final used = _hexColor
            .allMatches(source)
            .map((m) => m.group(0)!.toUpperCase())
            .toSet();
        expect(used, isNotEmpty);
        expect(palette, containsAll(used));
        expect(source, isNot(contains('currentColor')));
      });
    }
  });

  group('every SVG parses', () {
    for (final file in [...icons, ...illustrations]) {
      final name = file.uri.pathSegments.last;
      testWidgets(name, (tester) async {
        final info = await tester.runAsync(
          () => vg.loadPicture(SvgStringLoader(file.readAsStringSync()), null),
        );
        expect(info, isNotNull);
        expect(info!.size.width, greaterThan(0));
        info.picture.dispose();
      });
    }
  });
}
