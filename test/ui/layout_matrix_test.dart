// Every screen, in every relevant state, on every supported screen size and
// system text size. A RenderFlex overflow or any layout exception fails the
// test, including in content that is only reached by scrolling.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/add_entry_screen.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/history_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/manage_exercises_screen.dart';
import 'package:one_rm_mobile/ui/onboarding_screen.dart';
import 'package:one_rm_mobile/ui/settings_screen.dart';
import 'package:one_rm_mobile/ui/widgets/pr_celebration.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

import '../helpers/devices.dart';
import '../helpers/test_app.dart';

typedef _Scenario = Future<void> Function(WidgetTester, TestDevice);

final _now = DateTime.now();

/// Longest name the app accepts.
final _longCustom = CustomExerciseData(
  id: 'custom_long',
  name: 'W' * ExerciseLibrary.maxNameLength,
);

final _squat = defaultExercises.firstWhere((e) => e.id == 'back_squat');

/// The longest built-in name.
final _sdhp = defaultExercises.firstWhere(
  (e) => e.id == 'sumo_deadlift_high_pull',
);

ExerciseRecord _record(double weight, int reps, int daysAgo) => ExerciseRecord(
  weight: weight,
  reps: reps,
  oneRM: calculateOneRM(weight, reps),
  date: _now.subtract(Duration(days: daysAgo)),
);

/// Months of squat history plus the heaviest value the form accepts, shown
/// in lbs, where numbers are widest.
Map<String, List<ExerciseRecord>> _sampleRecords() => {
  _squat.id: [
    for (var i = 0; i < 14; i++) _record(100 + i * 5, 5, 400 - i * 30),
    _record(180, 1, 1),
  ],
  _sdhp.id: [_record(WeightUnit.kg.maxWeight, maxReps, 3)],
  _longCustom.id: [_record(60, 8, 0)],
};

ExerciseLibrary _library({Set<String> hidden = const {}}) {
  final shown = {_sdhp.id};
  return ExerciseLibrary(
    ExerciseLibraryService.forTesting(
      custom: [_longCustom],
      hidden: hidden,
      shown: shown,
    ),
    custom: [_longCustom],
    hidden: hidden,
    shown: shown,
  );
}

RecordsRepository _records([Map<String, List<ExerciseRecord>>? data]) =>
    RecordsRepository(StorageService.inMemoryForTesting(), data ?? {});

Future<void> _pump(WidgetTester tester, TestDevice device, Widget home) async {
  await tester.pumpWidget(buildTestApp(home, platform: device.platform));
  await tester.pumpAndSettle();
}

Future<void> _onboardingPage(
  WidgetTester tester,
  TestDevice device,
  int page,
) async {
  await _pump(tester, device, OnboardingScreen(onComplete: (_) {}));
  for (var i = 0; i < page; i++) {
    await tester.tap(find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();
  }
}

Widget _detail(Map<String, List<ExerciseRecord>> data) => ExerciseDetailScreen(
  template: _squat,
  records: _records(data),
  unit: WeightUnit.lbs,
);

Widget _addEntry({ExerciseRecord? initial}) => AddEntryScreen(
  exerciseName: _sdhp.name,
  assetPath: _sdhp.assetPath,
  unit: WeightUnit.lbs,
  initial: initial,
);

final Map<String, _Scenario> _scenarios = {
  for (var page = 0; page < 4; page++)
    'onboarding page ${page + 1}': (t, d) => _onboardingPage(t, d, page),
  'home with records': (t, d) => _pump(
    t,
    d,
    HomeScreen(
      records: _records(_sampleRecords()),
      library: _library(),
      unitService: UnitService.forTesting(unit: WeightUnit.lbs),
    ),
  ),
  'home empty': (t, d) => _pump(
    t,
    d,
    HomeScreen(
      records: _records(),
      library: testLibrary(),
      unitService: UnitService.forTesting(),
    ),
  ),
  'home with everything hidden': (t, d) => _pump(
    t,
    d,
    HomeScreen(
      records: _records(),
      library: testLibrary(hidden: {for (final e in defaultExercises) e.id}),
      unitService: UnitService.forTesting(),
    ),
  ),
  'detail with records': (t, d) => _pump(t, d, _detail(_sampleRecords())),
  'detail reps table': (t, d) async {
    await _pump(t, d, _detail(_sampleRecords()));
    await t.scrollUntilVisible(
      find.byKey(const Key('table-REPS')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byKey(const Key('table-REPS')));
    await t.pumpAndSettle();
  },
  'detail empty': (t, d) => _pump(t, d, _detail({})),
  'add entry empty': (t, d) => _pump(t, d, _addEntry()),
  'add entry at the limits with the keyboard open': (t, d) async {
    await _pump(t, d, _addEntry());
    final fields = find.byType(TextFormField);
    await t.enterText(fields.at(0), '${WeightUnit.lbs.maxWeight}');
    await t.enterText(fields.at(1), '$maxReps');
    d.showKeyboard(t);
    await t.pumpAndSettle();
    expect(find.byKey(const Key('high-reps-warning')), findsOneWidget);
  },
  'edit entry': (t, d) => _pump(t, d, _addEntry(initial: _record(140, 3, 20))),
  'history': (t, d) => _pump(
    t,
    d,
    HistoryScreen(
      template: _sdhp,
      records: _records({
        _sdhp.id: [
          ..._sampleRecords()[_squat.id]!,
          ..._sampleRecords()[_sdhp.id]!,
        ],
      }),
      unit: WeightUnit.lbs,
    ),
  ),
  'manage exercises': (t, d) =>
      _pump(t, d, ManageExercisesScreen(library: _library())),
  'manage exercises with no search results': (t, d) async {
    await _pump(t, d, ManageExercisesScreen(library: _library()));
    await t.enterText(find.byKey(const Key('exercise-search')), 'zzz');
    await t.pumpAndSettle();
  },
  'new exercise dialog': (t, d) async {
    await _pump(t, d, ManageExercisesScreen(library: _library()));
    await t.tap(find.byKey(const Key('new-exercise-button')));
    await t.pumpAndSettle();
    await t.enterText(
      find.byKey(const Key('new-exercise-name')),
      _longCustom.name,
    );
    await t.pumpAndSettle();
  },
  'settings': (t, d) => _pump(
    t,
    d,
    SettingsScreen(
      unitService: UnitService.forTesting(),
      currentUnit: WeightUnit.kg,
    ),
  ),
  'PR celebration': (t, d) async {
    await _pump(
      t,
      d,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPrCelebration(
              context,
              exerciseName: _sdhp.name,
              oneRM: calculateOneRM(WeightUnit.kg.maxWeight, maxReps),
              previousBest: 100,
              unit: WeightUnit.lbs,
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('pr-celebration')), findsOneWidget);
  },
};

/// Scrolls every vertical list to its end so off-screen content is laid out
/// too.
Future<void> _scrollThroughEverything(WidgetTester tester) async {
  final scrollables = find
      .byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      )
      .evaluate()
      .map((e) => (e as StatefulElement).state as ScrollableState)
      .toList();
  for (final scrollable in scrollables) {
    final position = scrollable.position;
    while (position.pixels < position.maxScrollExtent) {
      position.jumpTo(
        math.min(
          position.pixels + position.viewportDimension * 0.8,
          position.maxScrollExtent,
        ),
      );
      await tester.pump();
    }
  }
}

void main() {
  for (final device in testDevices) {
    for (final scale in testTextScales) {
      group('$device · text ${(scale * 100).round()} %', () {
        _scenarios.forEach((name, scenario) {
          testWidgets(name, (tester) async {
            device.apply(tester, textScale: scale);
            await scenario(tester, device);
            await _scrollThroughEverything(tester);
            // Let timed UI (the PR celebration) finish before tear-down.
            await tester.pump(kPrCelebrationDuration);
            await tester.pumpAndSettle();
          });
        });
      });
    }
  }
}
