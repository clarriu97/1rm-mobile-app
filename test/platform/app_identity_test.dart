import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/ui/theme/app_colors.dart';

String _read(String path) => File(path).readAsStringSync();

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// PNG colour type from the IHDR chunk: 2 = RGB, 6 = RGBA.
int _pngColorType(String path) => File(path).readAsBytesSync()[25];

void main() {
  final background = _hex(AppColors.background.toARGB32());

  group('display name', () {
    test('iOS shows "1RM" under the icon', () {
      expect(
        _read('ios/Runner/Info.plist'),
        matches(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>1RM</string>'),
        ),
      );
    });

    test('Android shows "1RM" under the icon', () {
      expect(
        _read('android/app/src/main/AndroidManifest.xml'),
        contains('android:label="1RM"'),
      );
    });
  });

  group('app icon', () {
    test('iOS marketing icon has no alpha channel (App Store requirement)', () {
      expect(
        _pngColorType(
          'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
        ),
        2,
      );
    });

    test('Android adaptive icon has foreground, background and monochrome', () {
      final xml = _read(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      );
      expect(xml, contains('<background'));
      expect(xml, contains('<foreground'));
      expect(xml, contains('<monochrome'));
      expect(
        _read('android/app/src/main/res/values/colors.xml'),
        contains('<color name="ic_launcher_background">$background</color>'),
      );
    });

    test('branding sources referenced by the generators exist', () {
      for (final name in [
        'app_icon',
        'app_icon_foreground',
        'app_icon_monochrome',
        'splash',
        'splash_android12',
      ]) {
        expect(File('assets/branding/$name.png').existsSync(), isTrue);
        expect(File('assets/branding/$name.svg').existsSync(), isTrue);
      }
    });
  });

  group('launch screen never flashes white', () {
    test('iOS storyboard base colour is the app background', () {
      final storyboard = _read('ios/Runner/Base.lproj/LaunchScreen.storyboard');
      expect(storyboard, contains('image="LaunchBackground"'));
      expect(storyboard, isNot(contains('red="1" green="1" blue="1"')));
    });

    test('Android themes are dark in day and night mode', () {
      for (final dir in [
        'values',
        'values-v31',
        'values-night',
        'values-night-v31',
      ]) {
        final styles = _read('android/app/src/main/res/$dir/styles.xml');
        expect(styles, isNot(contains('Theme.Light')), reason: dir);
        expect(
          styles,
          contains(
            '<item name="android:windowBackground">@color/app_background</item>',
          ),
          reason: dir,
        );
      }
      expect(
        _read('android/app/src/main/res/values/colors.xml'),
        contains('<color name="app_background">$background</color>'),
      );
    });

    test('Android 12+ splash uses the app background', () {
      expect(
        _read('android/app/src/main/res/values-v31/styles.xml'),
        contains(
          '<item name="android:windowSplashScreenBackground">$background</item>',
        ),
      );
    });
  });
}
