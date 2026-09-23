import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';

void main() {
  group('DefaultExercises', () {
    test('has exactly 6 exercises', () {
      expect(defaultExercises.length, 6);
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
      expect(legacyExerciseIds.values.toSet(), ids);
      for (final exercise in defaultExercises) {
        expect(legacyExerciseIds[exercise.name], exercise.id);
      }
    });

    test('all exercises have non-empty names', () {
      for (final ex in defaultExercises) {
        expect(ex.name.isNotEmpty, isTrue);
      }
    });
  });
}
