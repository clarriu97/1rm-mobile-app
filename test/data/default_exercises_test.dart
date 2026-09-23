import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';

void main() {
  group('DefaultExercises', () {
    test('has the 10 built-in lifts', () {
      expect(defaultExercises.length, 10);
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
}
