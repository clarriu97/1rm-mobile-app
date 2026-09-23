import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';
import 'package:one_rm_mobile/services/unit_service.dart';
import 'package:one_rm_mobile/ui/exercise_detail_screen.dart';
import 'package:one_rm_mobile/ui/home_screen.dart';
import 'package:one_rm_mobile/ui/manage_exercises_screen.dart';

import '../helpers/test_app.dart';

Future<void> _pumpManage(WidgetTester tester, ExerciseLibrary library) async {
  await tester.pumpWidget(
    buildTestApp(ManageExercisesScreen(library: library)),
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

      await tester.scrollUntilVisible(
        find.byKey(const Key('toggle-snatch')),
        200,
      );
      final snatch = tester.widget<SwitchListTile>(
        find.byKey(const Key('toggle-snatch')),
      );
      expect(snatch.value, isFalse);
    });

    testWidgets('toggling hides and shows an exercise', (tester) async {
      final library = testLibrary();
      await _pumpManage(tester, library);

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
      await tester.scrollUntilVisible(find.text('Zercher Squat'), 200);
      expect(find.text('Custom'), findsOneWidget);
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
}
