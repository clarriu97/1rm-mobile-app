// Screenshots of the key screens, compared pixel by pixel. After an
// intentional visual change, regenerate them on macOS with:
//   flutter test --update-goldens --tags golden
// and review the PNG diff in the pull request.
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/manage_exercises_screen.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

import '../helpers/devices.dart';
import '../helpers/test_app.dart';

final _now = DateTime(2026, 9, 23, 10);
DateTime _clock() => _now;

final _squat = defaultExercises.firstWhere((e) => e.id == 'back_squat');

ExerciseRecord _record(double weight, int reps, DateTime date) =>
    ExerciseRecord(
      weight: weight,
      reps: reps,
      oneRM: calculateOneRM(weight, reps),
      date: date,
    );

RecordsRepository _records() => RecordsRepository(
  StorageService.inMemoryForTesting(),
  {
    _squat.id: [
      for (var i = 0; i < 10; i++)
        _record(100 + i * 7.5, 5, DateTime(2026, 1 + (i * 0.8).floor(), 3 + i)),
      _record(170, 2, DateTime(2026, 9, 22, 18)),
    ],
    'bench_press': [
      _record(80, 5, DateTime(2026, 6, 2)),
      _record(85, 5, DateTime(2026, 7, 14)),
      _record(90, 3, DateTime(2026, 9, 19)),
    ],
    'deadlift': [_record(180, 3, DateTime(2026, 8, 30))],
  },
);

/// The two most common iPhone widths: compact (SE) and standard (Pro).
final _devices = {
  'iphone_se': testDevices.firstWhere((d) => d.name == 'iPhone SE (3rd gen)'),
  'iphone_pro': testDevices.firstWhere((d) => d.name == 'iPhone 16 Pro'),
};

/// SVGs decode asynchronously from the asset bundle; load them for real and
/// rebuild so they appear in the capture.
Future<void> _loadSvgs(WidgetTester tester) async {
  final loaders = {
    for (final picture in tester.widgetList<SvgPicture>(
      find.byType(SvgPicture),
    ))
      picture.bytesLoader,
  };
  await tester.runAsync(() async {
    for (final loader in loaders) {
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  });
  await tester.pumpAndSettle();
}

typedef _Screen = Future<void> Function(WidgetTester);

Future<void> _show(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(buildTestApp(home, platform: TargetPlatform.iOS));
  await tester.pumpAndSettle();
}

final Map<String, _Screen> _screens = {
  'onboarding_welcome': (t) => _show(t, OnboardingScreen(onComplete: (_) {})),
  'onboarding_lifts': (t) async {
    await _show(t, OnboardingScreen(onComplete: (_) {}));
    for (var i = 0; i < 3; i++) {
      await t.tap(find.byKey(const Key('onboarding-next-button')));
      await t.pumpAndSettle();
    }
  },
  'home': (t) => _show(
    t,
    HomeScreen(
      records: _records(),
      library: testLibrary(),
      unitService: UnitService.forTesting(),
      clock: _clock,
    ),
  ),
  'detail': (t) => _show(
    t,
    ExerciseDetailScreen(
      template: _squat,
      records: _records(),
      unit: WeightUnit.kg,
      clock: _clock,
    ),
  ),
  'add_entry': (t) async {
    await _show(
      t,
      AddEntryScreen(
        exerciseName: _squat.name,
        assetPath: _squat.assetPath,
        unit: WeightUnit.kg,
        clock: _clock,
      ),
    );
    final fields = find.byType(TextFormField);
    await t.enterText(fields.at(0), '140');
    await t.enterText(fields.at(1), '5');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  },
  'history': (t) => _show(
    t,
    HistoryScreen(
      template: _squat,
      records: _records(),
      unit: WeightUnit.kg,
      clock: _clock,
    ),
  ),
  'manage_exercises': (t) =>
      _show(t, ManageExercisesScreen(library: testLibrary())),
};

void main() {
  _devices.forEach((deviceName, device) {
    group(deviceName, () {
      _screens.forEach((screenName, show) {
        testWidgets(screenName, (tester) async {
          device.apply(tester);
          await show(tester);
          await _loadSvgs(tester);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/$screenName.$deviceName.png'),
          );
        });
      });
    });
  });
}
