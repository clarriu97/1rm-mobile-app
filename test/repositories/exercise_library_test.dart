import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/repositories/exercise_library.dart';
import 'package:one_rm_mobile/services/exercise_library_service.dart';

void main() {
  ExerciseLibrary library({
    List<CustomExerciseData> custom = const [],
    Set<String> hidden = const {},
    Set<String> shown = const {},
    ExerciseLibraryService? service,
  }) => ExerciseLibrary(
    service ?? ExerciseLibraryService.forTesting(),
    custom: custom,
    hidden: hidden,
    shown: shown,
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

    test('by default only the core lifts are visible', () {
      final lib = library();
      expect(lib.visible.map((e) => e.id), [
        for (final e in defaultExercises)
          if (e.defaultVisible) e.id,
      ]);
      expect(lib.isHidden('back_squat'), isFalse);
      expect(lib.isHidden('thruster'), isTrue);
    });

    test('custom exercises are visible by default', () {
      final lib = library(
        custom: const [CustomExerciseData(id: 'custom_1', name: 'Pin Press')],
      );
      expect(lib.isHidden('custom_1'), isFalse);
      expect(lib.visible.last.id, 'custom_1');
    });

    test('explicit choices override the defaults both ways', () {
      final lib = library(
        custom: const [CustomExerciseData(id: 'custom_1', name: 'Pin Press')],
        hidden: {'snatch', 'custom_1'},
        shown: {'thruster'},
      );

      final ids = lib.visible.map((e) => e.id);
      expect(ids, isNot(contains('snatch')));
      expect(ids, isNot(contains('custom_1')));
      expect(ids, contains('thruster'));
      expect(ids, contains('back_squat'));
    });

    test('hidden wins if an id is in both override sets', () {
      final lib = library(hidden: {'thruster'}, shown: {'thruster'});
      expect(lib.isHidden('thruster'), isTrue);
    });

    test('unknown ids report hidden only when explicitly hidden', () {
      final lib = library(hidden: {'gone'});
      expect(lib.isHidden('gone'), isTrue);
      expect(lib.isHidden('never_seen'), isFalse);
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
      expect(await service.loadShown(), {'snatch'});

      expect(notifications, 2);
    });

    test('setHidden can show a lift that is hidden by default', () async {
      final service = ExerciseLibraryService.forTesting();
      final lib = library(service: service);

      await lib.setHidden('thruster', hidden: false);

      expect(lib.isHidden('thruster'), isFalse);
      expect(await service.loadShown(), {'thruster'});
    });

    test('setVisibleExactly only records what actually changes', () async {
      final service = ExerciseLibraryService.forTesting();
      final lib = library(service: service);
      final core = {
        for (final e in defaultExercises)
          if (e.defaultVisible) e.id,
      };

      await lib.setVisibleExactly({
        ...core.where((id) => id != 'snatch'),
        'thruster',
      });

      expect(lib.isHidden('snatch'), isTrue);
      expect(lib.isHidden('thruster'), isFalse);
      expect(lib.isHidden('back_squat'), isFalse);
      expect(await service.loadHidden(), {'snatch'});
      expect(await service.loadShown(), {'thruster'});
    });

    test('setVisibleExactly with the current selection is a no-op', () async {
      final service = ExerciseLibraryService.forTesting();
      final lib = library(service: service);
      var notifications = 0;
      lib.addListener(() => notifications++);

      await lib.setVisibleExactly({for (final e in lib.visible) e.id});

      expect(notifications, 0);
      expect(await service.loadHidden(), isEmpty);
      expect(await service.loadShown(), isEmpty);
    });

    test('load reads what the service stored', () async {
      final service = ExerciseLibraryService.forTesting(
        custom: const [CustomExerciseData(id: 'custom_9', name: 'Pin Press')],
        hidden: {'deadlift'},
        shown: {'thruster'},
      );

      final lib = await ExerciseLibrary.load(service);

      expect(lib.all.last.name, 'Pin Press');
      expect(lib.isHidden('deadlift'), isTrue);
      expect(lib.isHidden('thruster'), isFalse);
    });
  });
}
