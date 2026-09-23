import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:one_rm_mobile/main.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes the binding and wipes every piece of app data before each
/// test, so each flow starts like a fresh install.
void setUpE2E() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(_resetAppData);
}

Future<void> _resetAppData() async {
  await (await SharedPreferences.getInstance()).clear();
  final documents = await getApplicationDocumentsDirectory();
  for (final entry in documents.listSync()) {
    if (entry is File && entry.uri.pathSegments.last.startsWith('records')) {
      entry.deleteSync();
    }
  }
}

/// Starts the app exactly like `main()` does, on the real device storage.
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(await loadApp());
  // The app shows a spinner while it reads whether onboarding is done.
  await waitFor(tester, find.byType(CircularProgressIndicator), gone: true);
}

/// Kills and reopens the app: throws the whole widget tree away and rebuilds
/// every repository from what is on disk.
Future<void> relaunchApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  // The moment between closing and reopening: lets writes already in flight
  // land, as they would on a phone. (A kill in the middle of a write is
  // covered by the atomic-save tests of StorageService.)
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  await (await SharedPreferences.getInstance()).reload();
  await launchApp(tester);
}

/// The screen's main vertical list (not a horizontal PageView).
final _mainList = find
    .byWidgetPredicate(
      (w) =>
          w is Scrollable &&
          axisDirectionToAxis(w.axisDirection) == Axis.vertical,
    )
    .first;

/// Scrolls the main list down to [finder] only if it is not on screen yet
/// (like a user would, without jumping the list around).
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.hitTestable().evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(finder, 200, scrollable: _mainList);
  await tester.pumpAndSettle();
}

/// Expects exactly one [finder] on screen, scrolling down to it if needed:
/// small phones show less of each screen.
Future<void> expectOnScreen(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  expect(finder, findsOneWidget);
}

Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) =>
    _scrollAndTap(tester, find.byKey(Key(key)));

/// Walks through the onboarding picking [unit] and keeping the default lifts.
Future<void> completeOnboarding(
  WidgetTester tester, {
  WeightUnit unit = WeightUnit.kg,
}) async {
  await tapKey(tester, 'onboarding-next-button');
  await tapKey(tester, 'onboarding-next-button');
  await tapKey(tester, 'unit-option-${unit.name}');
  await tapKey(tester, 'onboarding-next-button');
  await tapKey(tester, 'onboarding-next-button');
  await waitFor(tester, find.text('1RM'));
}

/// Types into the field with [key] and closes the keyboard, which on a
/// device covers the lower half of the screen.
Future<void> typeInto(WidgetTester tester, String key, String text) async {
  final field = find.byKey(Key(key));
  if (field.evaluate().isEmpty) {
    await tester.scrollUntilVisible(field, -200, scrollable: _mainList);
  }
  // Focus it with a tap first, as a user does: after the keyboard was
  // closed, enterText alone does not reconnect the text input.
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) =>
    _scrollAndTap(tester, find.text(text));

/// From an exercise's detail screen, logs weight × reps and returns there.
Future<void> logEntry(
  WidgetTester tester, {
  required String weight,
  required String reps,
}) async {
  await tapKey(tester, 'add-entry-button');
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), weight);
  await tester.enterText(fields.at(1), reps);
  await tester.pumpAndSettle();
  await tapKey(tester, 'save-entry-button');
}

/// Pumps real frames until [finder] matches (or stops matching, with
/// [gone]): for UI that waits on real timers (the PR celebration) or on disk
/// and preferences writes, which `pumpAndSettle` does not wait for.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  bool gone = false,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isNotEmpty == gone) {
    if (DateTime.now().isAfter(end)) {
      fail('Timed out waiting for $finder${gone ? ' to disappear' : ''}');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// Back navigation the way users do it: the iOS edge swipe, the Android
/// back button.
Future<void> goBack(WidgetTester tester) async {
  if (Platform.isIOS) {
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await tester.timedDragFrom(
      const Offset(2, 300),
      Offset(width * 0.8, 0),
      const Duration(milliseconds: 300),
    );
  } else {
    await tester.binding.handlePopRoute();
  }
  await tester.pumpAndSettle();
}
