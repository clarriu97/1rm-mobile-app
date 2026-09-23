import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/models/exercise.dart';

void main() {
  group('DefaultExercises', () {
    test('has the 34 built-in lifts', () {
      expect(defaultExercises.length, 34);
    });

    test('ids shipped in earlier versions still exist', () {
      final ids = defaultExercises.map((e) => e.id).toSet();
      expect(
        ids,
        containsAll(const [
          'back_squat',
          'front_squat',
          'bench_press',
          'deadlift',
          'power_clean',
          'snatch',
          'overhead_press',
          'push_press',
          'barbell_row',
          'clean_and_jerk',
        ]),
      );
    });

    test('ten core lifts are visible by default', () {
      expect(defaultExercises.where((e) => e.defaultVisible).map((e) => e.id), [
        'back_squat',
        'front_squat',
        'deadlift',
        'bench_press',
        'overhead_press',
        'push_press',
        'power_clean',
        'squat_clean',
        'clean_and_jerk',
        'snatch',
      ]);
    });

    test('built-ins are listed family by family, no custom family', () {
      final order = defaultExercises.map((e) => e.category.index).toList();
      expect(order, [...order]..sort());
      expect(
        defaultExercises.map((e) => e.category).toSet(),
        ExerciseCategory.values.toSet()..remove(ExerciseCategory.custom),
      );
    });

    test('every exercise has its own icon', () {
      final icons = defaultExercises.map((e) => e.assetPath).toSet();
      expect(icons.length, defaultExercises.length);
      for (final e in defaultExercises) {
        expect(e.assetPath, 'assets/icons/${e.id}.svg');
      }
    });

    test('all exercises have unique names', () {
      final names = defaultExercises.map((e) => e.name).toSet();
      expect(names.length, defaultExercises.length);
    });

    test('all exercises have unique snake_case ids', () {
      final ids = defaultExercises.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z]+(_[a-z]+)*$')));
      }
    });

    test('every legacy name maps to an existing exercise id', () {
      final ids = defaultExercises.map((e) => e.id).toSet();
      expect(ids, containsAll(legacyExerciseIds.values));
      for (final entry in legacyExerciseIds.entries) {
        final exercise = defaultExercises.firstWhere(
          (e) => e.id == entry.value,
        );
        expect(exercise.name, entry.key, reason: 'v1 name must still map');
      }
    });

    test('all exercises have non-empty names', () {
      for (final ex in defaultExercises) {
        expect(ex.name.isNotEmpty, isTrue);
      }
    });
  });

  group('groupByCategory', () {
    test('keeps family order and exercise order, skipping empty families', () {
      final picked = [
        defaultExercises.firstWhere((e) => e.id == 'snatch'),
        defaultExercises.firstWhere((e) => e.id == 'front_squat'),
        defaultExercises.firstWhere((e) => e.id == 'back_squat'),
      ];

      final groups = groupByCategory(picked);

      expect(groups.map((g) => g.$1), [
        ExerciseCategory.squat,
        ExerciseCategory.snatch,
      ]);
      expect(groups.first.$2.map((e) => e.id), ['front_squat', 'back_squat']);
    });

    test('empty input gives no groups', () {
      expect(groupByCategory(const []), isEmpty);
    });
  });
}
