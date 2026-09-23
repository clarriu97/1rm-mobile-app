import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';

void main() {
  ExerciseLibrary library({
    List<CustomExerciseData> custom = const [],
    Set<String> hidden = const {},
    ExerciseLibraryService? service,
  }) => ExerciseLibrary(
    service ?? ExerciseLibraryService.forTesting(),
    custom: custom,
    hidden: hidden,
    clock: () => DateTime(2026, 9, 23),
  );

  group('ExerciseLibrary — listing', () {
    test('built-ins first in their fixed order, then customs', () {
      final lib = library(
        custom: const [CustomExerciseData(id: 'custom_1', name: 'Pin Press')],
      );

      expect(lib.all.take(defaultExercises.length).map((e) => e.id), [
        for (final e in defaultExercises) e.id,
      ]);
      expect(lib.all.last.name, 'Pin Press');
      expect(lib.all.last.assetPath, customExerciseIcon);
      expect(lib.isCustom('custom_1'), isTrue);
      expect(lib.isCustom('back_squat'), isFalse);
    });

    test('visible excludes hidden built-ins and customs', () {
      final lib = library(
        custom: const [CustomExerciseData(id: 'custom_1', name: 'Pin Press')],
        hidden: {'snatch', 'custom_1'},
      );

      final ids = lib.visible.map((e) => e.id);
      expect(ids, isNot(contains('snatch')));
      expect(ids, isNot(contains('custom_1')));
      expect(ids, contains('back_squat'));
      expect(lib.visible, hasLength(defaultExercises.length - 1));
    });

    test('everything hidden gives an empty visible list', () {
      final lib = library(hidden: {for (final e in defaultExercises) e.id});
      expect(lib.visible, isEmpty);
    });
  });

  group('ExerciseLibrary — validateName', () {
    final lib = library(
      custom: const [CustomExerciseData(id: 'custom_1', name: 'Pin Press')],
    );

    test('accepts a new name', () {
      expect(lib.validateName('Zercher Squat'), isNull);
    });

    test('rejects empty and whitespace-only names', () {
      expect(lib.validateName(''), ExerciseNameError.empty);
      expect(lib.validateName('   '), ExerciseNameError.empty);
    });

    test('rejects names over the limit after trimming', () {
      final max = 'x' * ExerciseLibrary.maxNameLength;
      expect(lib.validateName('  $max  '), isNull);
      expect(lib.validateName('${max}x'), ExerciseNameError.tooLong);
    });

    test('rejects duplicates of built-in or custom names, any case', () {
      expect(lib.validateName('back squat'), ExerciseNameError.duplicate);
      expect(lib.validateName(' PIN PRESS '), ExerciseNameError.duplicate);
    });
  });

  group('ExerciseLibrary — mutations', () {
    test(
      'addCustom trims, persists, notifies and returns the template',
      () async {
        final service = ExerciseLibraryService.forTesting();
        final lib = library(service: service);
        var notifications = 0;
        lib.addListener(() => notifications++);

        final created = await lib.addCustom('  Zercher Squat ');

        expect(created.name, 'Zercher Squat');
        expect(created.id, startsWith('custom_'));
        expect(lib.all.last.id, created.id);
        expect(lib.visible.last.id, created.id);
        expect((await service.loadCustom()).single.name, 'Zercher Squat');
        expect(notifications, 1);
      },
    );

    test('addCustom gives unique ids even at the same instant', () async {
      final lib = library();
      final a = await lib.addCustom('A');
      final b = await lib.addCustom('B');
      expect(a.id, isNot(b.id));
    });

    test('addCustom rejects invalid names without changing anything', () async {
      final service = ExerciseLibraryService.forTesting();
      final lib = library(service: service);

      await expectLater(lib.addCustom(''), throwsArgumentError);
      await expectLater(lib.addCustom('Deadlift'), throwsArgumentError);

      expect(lib.all, hasLength(defaultExercises.length));
      expect(await service.loadCustom(), isEmpty);
    });

    test('setHidden hides and shows, persisting only real changes', () async {
      final service = ExerciseLibraryService.forTesting();
      final lib = library(service: service);
      var notifications = 0;
      lib.addListener(() => notifications++);

      await lib.setHidden('snatch', hidden: true);
      await lib.setHidden('snatch', hidden: true);
      expect(lib.isHidden('snatch'), isTrue);
      expect(await service.loadHidden(), {'snatch'});

      await lib.setHidden('snatch', hidden: false);
      await lib.setHidden('snatch', hidden: false);
      expect(lib.isHidden('snatch'), isFalse);
      expect(await service.loadHidden(), isEmpty);

      expect(notifications, 2);
    });

    test('load reads what the service stored', () async {
      final service = ExerciseLibraryService.forTesting(
        custom: const [CustomExerciseData(id: 'custom_9', name: 'Pin Press')],
        hidden: {'deadlift'},
      );

      final lib = await ExerciseLibrary.load(service);

      expect(lib.all.last.name, 'Pin Press');
      expect(lib.isHidden('deadlift'), isTrue);
    });
  });
}
