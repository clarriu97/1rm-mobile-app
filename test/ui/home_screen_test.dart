import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/widgets/sparkline.dart';

import '../helpers/semantics.dart';
import '../helpers/test_app.dart';

final _squat = defaultExercises.first;
final _bench = defaultExercises.firstWhere((e) => e.id == 'bench_press');

ExerciseRecord _record(double oneRM, {DateTime? date}) => ExerciseRecord(
  weight: oneRM,
  reps: 1,
  oneRM: oneRM,
  date: date ?? DateTime.now(),
);

Future<void> _pumpHome(
  WidgetTester tester,
  Map<String, List<ExerciseRecord>> data, {
  WeightUnit unit = WeightUnit.kg,
  ExerciseLibrary? library,
}) async {
  await tester.pumpWidget(
    buildTestApp(
      HomeScreen(
        records: RecordsRepository(StorageService.inMemoryForTesting(), data),
        library: library ?? testLibrary(),
        unitService: UnitService.forTesting(unit: unit),
        language: testLanguage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen — empty', () {
    testWidgets('shows the first-lift hint and every exercise', (tester) async {
      await _pumpHome(tester, {});

      expect(find.text('LOG YOUR FIRST LIFT'), findsOneWidget);
      for (final exercise in defaultExercises.where((e) => e.defaultVisible)) {
        await tester.scrollUntilVisible(find.text(exercise.name), 100);
        expect(find.text(exercise.name), findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('manage-exercises-button')),
        100,
      );
      expect(find.text('Thruster'), findsNothing);
      expect(find.byType(Sparkline), findsNothing);
    });
  });

  group('HomeScreen — with records', () {
    testWidgets('hides the hint and shows best 1RM and last session', (
      tester,
    ) async {
      await _pumpHome(tester, {
        _squat.id: [
          _record(140, date: DateTime.now().subtract(const Duration(days: 9))),
          _record(150, date: DateTime.now().subtract(const Duration(days: 2))),
        ],
      });

      expect(find.text('LOG YOUR FIRST LIFT'), findsNothing);
      expect(find.text('150.0 kg'), findsOneWidget);
      expect(find.text('2 days ago'), findsOneWidget);
      expect(find.text('No records yet'), findsWidgets);
    });

    testWidgets('shows a trend line only with two or more entries', (
      tester,
    ) async {
      await _pumpHome(tester, {
        _squat.id: [_record(140), _record(150)],
        _bench.id: [_record(100)],
      });

      expect(find.byType(Sparkline), findsOneWidget);
      final sparkline = tester.widget<Sparkline>(find.byType(Sparkline));
      expect(sparkline.values, [140, 150]);
    });

    testWidgets('trend is chronological and keeps the last 12 entries', (
      tester,
    ) async {
      final start = DateTime(2026);
      final records = [
        for (var i = 0; i < 15; i++)
          _record(100.0 + i, date: start.add(Duration(days: i))),
      ].reversed.toList();

      await _pumpHome(tester, {_squat.id: records});

      final values = tester.widget<Sparkline>(find.byType(Sparkline)).values;
      expect(values, hasLength(12));
      expect(values.first, 103);
      expect(values.last, 114);
    });

    testWidgets('shows weights in the selected unit', (tester) async {
      await _pumpHome(tester, {
        _squat.id: [_record(100)],
      }, unit: WeightUnit.lbs);

      expect(find.text('220.5 lbs'), findsOneWidget);
    });

    testWidgets('tapping a card opens its detail screen', (tester) async {
      await _pumpHome(tester, {});

      await tester.tap(find.text(_bench.name));
      await tester.pumpAndSettle();

      final detail = tester.widget<ExerciseDetailScreen>(
        find.byType(ExerciseDetailScreen),
      );
      expect(detail.template.id, _bench.id);
    });
  });

  group('HomeScreen — layout', () {
    testWidgets('cards are large tap targets', (tester) async {
      await _pumpHome(tester, {});

      final card = find.ancestor(
        of: find.text(_squat.name),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(card).height, greaterThanOrEqualTo(84));
    });

    testWidgets('no overflow on a small phone with 200 % text', (tester) async {
      tester.view.physicalSize = const Size(320, 640) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: buildTestApp(
            HomeScreen(
              records: RecordsRepository(StorageService.inMemoryForTesting(), {
                _squat.id: [_record(987.5), _record(999.9)],
              }),
              library: testLibrary(),
              unitService: UnitService.forTesting(unit: WeightUnit.lbs),
              language: testLanguage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('relative dates count from the injected clock', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        HomeScreen(
          records: RecordsRepository(StorageService.inMemoryForTesting(), {
            _squat.id: [_record(150, date: DateTime(2026, 3, 9, 22))],
          }),
          library: testLibrary(),
          unitService: UnitService.forTesting(),
          language: testLanguage(),
          clock: () => DateTime(2026, 3, 10, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
  });
  group('HomeScreen in Spanish', () {
    testWidgets('names, relative dates and weights', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HomeScreen(
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              _squat.id: [_record(112.5, date: DateTime(2026, 9, 22, 18))],
            }),
            library: testLibrary(),
            unitService: UnitService.forTesting(),
            language: testLanguage(),
            clock: () => DateTime(2026, 9, 23, 10),
          ),
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sentadilla trasera'), findsOneWidget);
      expect(find.text('Ayer'), findsOneWidget);
      expect(find.text('112,5 kg'), findsOneWidget);
      expect(find.text('Aún no hay registros'), findsWidgets);
      expect(find.byTooltip('Ajustes'), findsOneWidget);
    });

    testWidgets('first-lift hint', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HomeScreen(
            records: RecordsRepository(StorageService.inMemoryForTesting()),
            library: testLibrary(),
            unitService: UnitService.forTesting(),
            language: testLanguage(),
          ),
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('APUNTA TU PRIMERA SERIE'), findsOneWidget);
    });
  });
  group('HomeScreen — screen reader', () {
    Future<SemanticsHandle> pump(WidgetTester tester, {Locale? locale}) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestApp(
          HomeScreen(
            records: RecordsRepository(StorageService.inMemoryForTesting(), {
              _squat.id: [_record(112.5, date: DateTime(2026, 9, 22, 18))],
            }),
            library: testLibrary(),
            unitService: UnitService.forTesting(),
            language: testLanguage(),
            clock: () => DateTime(2026, 9, 23, 10),
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      return semantics;
    }

    testWidgets('a card is one button that says the lift, its best and when', (
      tester,
    ) async {
      final semantics = await pump(tester);

      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Back Squat, best 1RM 112.5 kg, Yesterday'),
        ),
        isSemantics(isButton: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Front Squat, no records yet'),
        ),
        isSemantics(isButton: true, hasTapAction: true),
      );
      semantics.dispose();
    });

    testWidgets('in Spanish', (tester) async {
      final semantics = await pump(tester, locale: const Locale('es'));

      expect(
        find.bySemanticsLabel('Sentadilla trasera, mejor 1RM 112,5 kg, Ayer'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('exercise icons are decoration, not images', (tester) async {
      final semantics = await pump(tester);
      expect(imageLabels(tester), isEmpty);
      semantics.dispose();
    });
  });
}
