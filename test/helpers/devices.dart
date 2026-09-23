import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A real-world screen the app must lay out on: logical size, pixel density,
/// safe-area insets and platform.
class TestDevice {
  const TestDevice(
    this.name, {
    required this.size,
    required this.pixelRatio,
    required this.platform,
    this.padding = EdgeInsets.zero,
  });

  final String name;
  final Size size;
  final double pixelRatio;
  final TargetPlatform platform;

  /// System UI insets (status bar, notch, home indicator, navigation bar).
  final EdgeInsets padding;

  /// Applies this device to the test view; reset automatically on tear-down.
  void apply(WidgetTester tester, {double textScale = 1.0}) {
    tester.view
      ..physicalSize = size * pixelRatio
      ..devicePixelRatio = pixelRatio
      ..padding = _physical(padding)
      ..viewPadding = _physical(padding);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
  }

  /// Simulates the on-screen keyboard covering [height] logical pixels.
  void showKeyboard(WidgetTester tester, {double height = 300}) {
    tester.view.viewInsets = _physical(EdgeInsets.only(bottom: height));
  }

  FakeViewPadding _physical(EdgeInsets insets) => FakeViewPadding(
    left: insets.left * pixelRatio,
    top: insets.top * pixelRatio,
    right: insets.right * pixelRatio,
    bottom: insets.bottom * pixelRatio,
  );

  @override
  String toString() => name;
}

/// Smallest to largest screens the app supports (iPhone only on iOS; any
/// Android, including tablets, which Android 16 lets rotate freely).
const testDevices = [
  TestDevice(
    'iPhone SE (1st gen)',
    size: Size(320, 568),
    pixelRatio: 2,
    platform: TargetPlatform.iOS,
    padding: EdgeInsets.only(top: 20),
  ),
  TestDevice(
    'iPhone SE (3rd gen)',
    size: Size(375, 667),
    pixelRatio: 2,
    platform: TargetPlatform.iOS,
    padding: EdgeInsets.only(top: 20),
  ),
  TestDevice(
    'iPhone 16 Pro',
    size: Size(402, 874),
    pixelRatio: 3,
    platform: TargetPlatform.iOS,
    padding: EdgeInsets.only(top: 62, bottom: 34),
  ),
  TestDevice(
    'iPhone 16 Pro Max',
    size: Size(440, 956),
    pixelRatio: 3,
    platform: TargetPlatform.iOS,
    padding: EdgeInsets.only(top: 62, bottom: 34),
  ),
  TestDevice(
    'Android compact',
    size: Size(360, 640),
    pixelRatio: 3,
    platform: TargetPlatform.android,
    padding: EdgeInsets.only(top: 24, bottom: 48),
  ),
  TestDevice(
    'Pixel 9',
    size: Size(412, 915),
    pixelRatio: 2.625,
    platform: TargetPlatform.android,
    padding: EdgeInsets.only(top: 48, bottom: 24),
  ),
  TestDevice(
    'Android tablet portrait',
    size: Size(800, 1280),
    pixelRatio: 2,
    platform: TargetPlatform.android,
    padding: EdgeInsets.only(top: 24, bottom: 48),
  ),
  TestDevice(
    'Android tablet landscape',
    size: Size(1280, 800),
    pixelRatio: 2,
    platform: TargetPlatform.android,
    padding: EdgeInsets.only(top: 24, bottom: 48),
  ),
];

/// System text sizes: default, a common bump, and the 200 % we support.
const testTextScales = [1.0, 1.3, 2.0];
