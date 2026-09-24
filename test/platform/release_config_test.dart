import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/app_info.dart';

String _read(String path) => File(path).readAsStringSync();

/// The `<array>` or value that follows `<key>key</key>` in a plist.
String _plistValue(String plist, String key) {
  final match = RegExp(
    '<key>$key</key>\\s*(<array>.*?</array>|<array/>|<[a-z]+/>|<[a-z]+>[^<]*</[a-z]+>)',
    dotAll: true,
  ).firstMatch(plist);
  expect(match, isNotNull, reason: '$key is missing');
  return match!.group(1)!;
}

void main() {
  group('version', () {
    test('the version shown in the app is the one in pubspec.yaml', () {
      final version = RegExp(
        r'^version: (\d+\.\d+\.\d+)\+(\d+)$',
        multiLine: true,
      ).firstMatch(_read('pubspec.yaml'));
      expect(version, isNotNull);
      expect(appVersion, version!.group(1));
      expect(appBuildNumber, int.parse(version.group(2)!));
    });

    test('Android takes versionCode and versionName from pubspec', () {
      final gradle = _read('android/app/build.gradle.kts');
      expect(gradle, contains('versionCode = flutter.versionCode'));
      expect(gradle, contains('versionName = flutter.versionName'));
    });

    test('iOS takes the version and build number from pubspec', () {
      final plist = _read('ios/Runner/Info.plist');
      expect(
        _plistValue(plist, 'CFBundleShortVersionString'),
        r'<string>$(FLUTTER_BUILD_NAME)</string>',
      );
      expect(
        _plistValue(plist, 'CFBundleVersion'),
        r'<string>$(FLUTTER_BUILD_NUMBER)</string>',
      );
    });
  });

  group('iOS', () {
    final plist = _read('ios/Runner/Info.plist');

    test('portrait only', () {
      final orientations = RegExp(
        r'<string>(UIInterfaceOrientation\w+)</string>',
      ).allMatches(_plistValue(plist, 'UISupportedInterfaceOrientations'));
      expect(orientations.map((m) => m.group(1)), [
        'UIInterfaceOrientationPortrait',
      ]);
    });

    test('declares no non-exempt encryption (skips the export question)', () {
      expect(_plistValue(plist, 'ITSAppUsesNonExemptEncryption'), '<false/>');
    });

    test('privacy manifest: no tracking, no data collected, and the '
        'required reason for UserDefaults', () {
      final manifest = _read('ios/Runner/PrivacyInfo.xcprivacy');
      expect(_plistValue(manifest, 'NSPrivacyTracking'), '<false/>');
      expect(_plistValue(manifest, 'NSPrivacyTrackingDomains'), '<array/>');
      expect(_plistValue(manifest, 'NSPrivacyCollectedDataTypes'), '<array/>');
      final apis = _plistValue(manifest, 'NSPrivacyAccessedAPITypes');
      expect(apis, contains('NSPrivacyAccessedAPICategoryUserDefaults'));
      expect(apis, contains('<string>CA92.1</string>'));
    });

    test('the privacy manifest ships inside the app', () {
      final project = _read('ios/Runner.xcodeproj/project.pbxproj');
      expect(project, contains('PrivacyInfo.xcprivacy in Resources */,'));
    });

    test('one deployment target for every configuration', () {
      final targets = RegExp(
        r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);',
      ).allMatches(_read('ios/Runner.xcodeproj/project.pbxproj'));
      expect(targets.map((m) => m.group(1)).toSet(), {'15.0'});
    });
  });

  group('Android', () {
    final gradle = _read('android/app/build.gradle.kts');
    final manifest = _read('android/app/src/main/AndroidManifest.xml');

    test('release builds are minified and shrunk with R8', () {
      expect(gradle, contains('isMinifyEnabled = true'));
      expect(gradle, contains('isShrinkResources = true'));
      expect(gradle, contains('proguard-android-optimize.txt'));
    });

    test('release signing comes from key.properties, debug key otherwise', () {
      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(gradle, contains('signingConfigs.findByName("release")'));
      expect(gradle, contains('?: signingConfigs.getByName("debug")'));
    });

    test('the keystore and its passwords never reach git', () {
      final ignored = Process.runSync('git', [
        'check-ignore',
        'android/key.properties',
        'android/app/upload-keystore.jks',
      ]);
      expect(ignored.exitCode, 0);
      expect((ignored.stdout as String).trim().split('\n'), hasLength(2));
    });

    test('phones are locked to portrait', () {
      expect(manifest, contains('android:screenOrientation="portrait"'));
    });

    test('the About links can open the browser and the mail app', () {
      expect(manifest, contains('<data android:scheme="https"/>'));
      expect(manifest, contains('<data android:scheme="mailto"/>'));
    });
  });
}
