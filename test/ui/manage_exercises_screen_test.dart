import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/services/link_service.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/manage_exercises_screen.dart';

import '../helpers/test_app.dart';

Future<void> _pumpManage(
  WidgetTester tester,
  ExerciseLibrary library, {
  RecordsRepository? records,
  Locale? locale,
}) async {
  await tester.pumpWidget(
    buildTestApp(
      ManageExercisesScreen(
        library: library,
        records:
            records ?? RecordsRepository(StorageService.inMemoryForTesting()),
      ),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _showToggle(WidgetTester tester, String id) async {
  await tester.scrollUntilVisible(
    find.byKey(Key('toggle-$id')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _openDialogAndType(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('new-exercise-button')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('new-exercise-name')), name);
  await tester.tap(find.byKey(const Key('create-exercise-button')));
  await tester.pumpAndSettle();
}

void main() {
  group('ManageExercisesScreen', () {
    testWidgets('lists every exercise with its visibility', (tester) async {
      final library = testLibrary(hidden: {'snatch'});
      await _pumpManage(tester, library);

      final squat = tester.widget<SwitchListTile>(
        find.byKey(const Key('toggle-back_squat')),
      );
      expect(squat.value, isTrue);

      await _showToggle(tester, 'snatch');
      final snatch = tester.widget<SwitchListTile>(
        find.byKey(const Key('toggle-snatch')),
      );
      expect(snatch.value, isFalse);
    });

    testWidgets('toggling hides and shows an exercise', (tester) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await _showToggle(tester, 'deadlift');
      await tester.tap(find.byKey(const Key('toggle-deadlift')));
      await tester.pumpAndSettle();
      expect(library.isHidden('deadlift'), isTrue);

      await tester.tap(find.byKey(const Key('toggle-deadlift')));
      await tester.pumpAndSettle();
      expect(library.isHidden('deadlift'), isFalse);
    });

    testWidgets('creates a custom exercise', (tester) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await _openDialogAndType(tester, '  Zercher Squat ');

      expect(find.byType(AlertDialog), findsNothing);
      expect(library.all.last.name, 'Zercher Squat');
      await tester.scrollUntilVisible(
        find.text('Zercher Squat'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('CUSTOM'), findsOneWidget);
    });

    testWidgets('lists families as sections and counts what is shown', (
      tester,
    ) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      expect(find.text('SQUAT'), findsOneWidget);
      expect(
        find.text(
          '${library.visible.length} of ${library.all.length} shown on Home',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('toggle-overhead_squat')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          '${library.visible.length} of ${library.all.length} shown on Home',
        ),
        findsOneWidget,
      );
      expect(library.isHidden('overhead_squat'), isFalse);
    });

    testWidgets('search filters by name, any case', (tester) async {
      await _pumpManage(tester, testLibrary());

      await tester.enterText(find.byKey(const Key('exercise-search')), 'CLEAN');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('toggle-power_clean')), findsOneWidget);
      expect(find.byKey(const Key('toggle-hang_squat_clean')), findsOneWidget);
      expect(find.byKey(const Key('toggle-back_squat')), findsNothing);
      expect(find.text('SQUAT'), findsNothing);
      expect(find.text('CLEAN & JERK'), findsOneWidget);
    });

    testWidgets('search with no matches says so; clearing restores the list', (
      tester,
    ) async {
      await _pumpManage(tester, testLibrary());

      await tester.enterText(find.byKey(const Key('exercise-search')), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No exercises match "zzz".'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('toggle-back_squat')), findsOneWidget);
    });

    testWidgets('empty name shows an error and keeps the dialog open', (
      tester,
    ) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await _openDialogAndType(tester, '   ');

      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(library.all, hasLength(defaultExercises.length));
    });

    testWidgets('duplicate name shows an error; typing clears it', (
      tester,
    ) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await _openDialogAndType(tester, 'deadlift');
      expect(find.text('That exercise already exists'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('new-exercise-name')),
        'Deficit Deadlift',
      );
      await tester.pump();
      expect(find.text('That exercise already exists'), findsNothing);
    });

    testWidgets('in Spanish, lists translated names and families', (
      tester,
    ) async {
      await _pumpManage(tester, testLibrary(), locale: const Locale('es'));

      expect(find.text('Ejercicios'), findsOneWidget);
      expect(find.text('Sentadilla trasera'), findsOneWidget);
      expect(find.text('SENTADILLA'), findsOneWidget);
      expect(find.text('10 de 34 en Inicio'), findsOneWidget);
    });

    testWidgets('in Spanish, search matches both the Spanish and the '
        'English name', (tester) async {
      await _pumpManage(tester, testLibrary(), locale: const Locale('es'));

      await tester.enterText(
        find.byKey(const Key('exercise-search')),
        'muerto',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('toggle-deadlift')), findsOneWidget);
      expect(find.byKey(const Key('toggle-romanian_deadlift')), findsOneWidget);
      expect(find.byKey(const Key('toggle-back_squat')), findsNothing);

      await tester.enterText(find.byKey(const Key('exercise-search')), 'squat');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('toggle-back_squat')), findsOneWidget);
      expect(find.text('Sentadilla trasera'), findsOneWidget);
    });

    testWidgets('in Spanish, no matches quotes the search', (tester) async {
      await _pumpManage(tester, testLibrary(), locale: const Locale('es'));

      await tester.enterText(find.byKey(const Key('exercise-search')), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Ningún ejercicio coincide con «zzz».'), findsOneWidget);
    });

    testWidgets('in Spanish, a translated or English name is a duplicate', (
      tester,
    ) async {
      final library = testLibrary();
      await _pumpManage(tester, library, locale: const Locale('es'));

      await _openDialogAndType(tester, 'peso muerto');
      expect(find.text('Ese ejercicio ya existe'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('new-exercise-name')),
        'Deadlift',
      );
      await tester.tap(find.byKey(const Key('create-exercise-button')));
      await tester.pumpAndSettle();
      expect(find.text('Ese ejercicio ya existe'), findsOneWidget);
      expect(library.all, hasLength(defaultExercises.length));
    });

    testWidgets('cancel creates nothing', (tester) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await tester.tap(find.byKey(const Key('new-exercise-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('new-exercise-name')),
        'Pin Press',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(library.all, hasLength(defaultExercises.length));
    });

    testWidgets('names are capped at the maximum length', (tester) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

      await _openDialogAndType(tester, 'x' * 60);

      expect(library.all.last.name.length, ExerciseLibrary.maxNameLength);
    });
  });

  group('HomeScreen with the library', () {
    Future<void> pumpHome(WidgetTester tester, ExerciseLibrary library) async {
      await tester.pumpWidget(
        buildTestApp(
          HomeScreen(
            records: RecordsRepository(StorageService.inMemoryForTesting()),
            library: library,
            unitService: UnitService.forTesting(),
            language: testLanguage(),
            links: LinkService.forTesting(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hidden exercises are not shown', (tester) async {
      await pumpHome(tester, testLibrary(hidden: {'back_squat'}));

      expect(find.text('Back Squat'), findsNothing);
      expect(find.text('Front Squat'), findsOneWidget);
    });

    testWidgets('all hidden shows a hint and the manage button', (
      tester,
    ) async {
      await pumpHome(
        tester,
        testLibrary(hidden: {for (final e in defaultExercises) e.id}),
      );

      expect(find.text('All exercises are hidden.'), findsOneWidget);
      expect(find.text('LOG YOUR FIRST LIFT'), findsNothing);
      expect(find.byKey(const Key('manage-exercises-button')), findsOneWidget);
    });

    testWidgets('a new custom exercise shows up on Home and can be logged', (
      tester,
    ) async {
      final library = testLibrary();
      await pumpHome(tester, library);

      await tester.scrollUntilVisible(
        find.byKey(const Key('manage-exercises-button')),
        300,
      );
      await tester.ensureVisible(
        find.byKey(const Key('manage-exercises-button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('manage-exercises-button')));
      await tester.pumpAndSettle();
      await _openDialogAndType(tester, 'Pin Press');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Pin Press'), 300);
      await tester.ensureVisible(find.text('Pin Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin Press'));
      await tester.pumpAndSettle();

      final detail = tester.widget<ExerciseDetailScreen>(
        find.byType(ExerciseDetailScreen),
      );
      expect(detail.template.assetPath, customExerciseIcon);
      expect(detail.template.id, startsWith('custom_'));
    });
  });
  group('ManageExercisesScreen — edit custom exercises', () {
    const typo = CustomExerciseData(id: 'custom_1', name: 'Zercer Squat');

    ExerciseLibrary withCustom({Set<String> hidden = const {}}) =>
        ExerciseLibrary(
          ExerciseLibraryService.forTesting(custom: [typo], hidden: hidden),
          custom: [typo],
          hidden: hidden,
        );

    ExerciseRecord entry(double weight) => ExerciseRecord(
      weight: weight,
      reps: 1,
      oneRM: weight,
      date: DateTime(2026, 9),
    );

    Future<void> openEditor(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('edit-custom_1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('edit-custom_1')));
      await tester.pumpAndSettle();
    }

    Future<void> saveName(WidgetTester tester, String name) async {
      await tester.enterText(find.byKey(const Key('edit-exercise-name')), name);
      await tester.tap(find.byKey(const Key('save-exercise-button')));
      await tester.pumpAndSettle();
    }

    testWidgets('only custom exercises can be edited', (tester) async {
      await _pumpManage(tester, withCustom());

      expect(find.byKey(const Key('edit-back_squat')), findsNothing);
      await openEditor(tester);
      expect(find.text('Edit exercise'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('edit-exercise-name')))
            .controller!
            .text,
        'Zercer Squat',
      );
    });

    testWidgets('renaming keeps the id and its records', (tester) async {
      final library = withCustom();
      final records = RecordsRepository(StorageService.inMemoryForTesting(), {
        'custom_1': [entry(100)],
      });
      await _pumpManage(tester, library, records: records);

      await openEditor(tester);
      await saveName(tester, ' Zercher Squat ');

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Zercher Squat'), findsOneWidget);
      expect(find.text('Zercer Squat'), findsNothing);
      expect(library.all.last.id, 'custom_1');
      expect(records.recordsFor('custom_1'), hasLength(1));
    });

    testWidgets('an invalid new name shows why and keeps the dialog', (
      tester,
    ) async {
      final library = withCustom();
      await _pumpManage(tester, library);
      await openEditor(tester);

      await saveName(tester, '  ');
      expect(find.text('Enter a name'), findsOneWidget);

      await saveName(tester, 'deadlift');
      expect(find.text('That exercise already exists'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(library.all.last.name, 'Zercer Squat');
    });

    testWidgets('its own name in another case is not a duplicate', (
      tester,
    ) async {
      final library = withCustom();
      await _pumpManage(tester, library);
      await openEditor(tester);

      await saveName(tester, 'ZERCER SQUAT');

      expect(library.all.last.name, 'ZERCER SQUAT');
    });

    testWidgets('cancel changes nothing', (tester) async {
      final library = withCustom();
      await _pumpManage(tester, library);
      await openEditor(tester);

      await tester.enterText(
        find.byKey(const Key('edit-exercise-name')),
        'Something else',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(library.all.last.name, 'Zercer Squat');
    });

    testWidgets('deleting removes it and its records, with undo', (
      tester,
    ) async {
      final library = withCustom(hidden: {'custom_1'});
      final records = RecordsRepository(StorageService.inMemoryForTesting(), {
        'custom_1': [entry(100), entry(110)],
      });
      await _pumpManage(tester, library, records: records);
      await openEditor(tester);

      await tester.tap(find.byKey(const Key('delete-exercise-button')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(library.isCustom('custom_1'), isFalse);
      expect(records.recordsFor('custom_1'), isEmpty);
      expect(find.text('Deleted Zercer Squat and 2 entries'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(library.isCustom('custom_1'), isTrue);
      expect(library.isHidden('custom_1'), isTrue);
      expect(records.recordsFor('custom_1'), hasLength(2));
    });

    testWidgets('deleting one without records says just its name', (
      tester,
    ) async {
      await _pumpManage(tester, withCustom());
      await openEditor(tester);

      await tester.tap(find.byKey(const Key('delete-exercise-button')));
      await tester.pumpAndSettle();

      expect(find.text('Deleted Zercer Squat'), findsOneWidget);
    });

    testWidgets('in Spanish', (tester) async {
      await _pumpManage(
        tester,
        withCustom(),
        records: RecordsRepository(StorageService.inMemoryForTesting(), {
          'custom_1': [entry(100)],
        }),
        locale: const Locale('es'),
      );

      await openEditor(tester);
      expect(find.byTooltip('Editar ejercicio'), findsOneWidget);
      expect(find.text('Editar ejercicio'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Borrado: Zercer Squat y 1 registro'), findsOneWidget);
      expect(find.text('Deshacer'), findsOneWidget);
    });
  });
}
