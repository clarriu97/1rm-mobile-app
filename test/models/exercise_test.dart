import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';

void main() {
  group('ExerciseRecord serialization', () {
    test('roundtrip preserves all fields', () {
      final original = ExerciseRecord(
        weight: 112.5,
        reps: 8,
        oneRM: 142.5,
        date: DateTime(2024, 6, 15, 14, 30),
      );

      final json = original.toJson();
      final restored = ExerciseRecord.fromJson(json);

      expect(restored.weight, original.weight);
      expect(restored.reps, original.reps);
      expect(restored.oneRM, original.oneRM);
      expect(restored.date, original.date);
    });
  });
  group('ExerciseRecord — tryFromJson', () {
    test('returns null for null input', () {
      expect(
        ExerciseRecord.tryFromJson({
          'weight': null,
          'reps': 5,
          'oneRM': 100,
          'date': '2024-01-15T10:00:00.000',
        }),
        isNull,
      );
    });

    test('returns null for missing fields', () {
      expect(ExerciseRecord.tryFromJson({'weight': 100}), isNull);
    });

    test('returns null for wrong types', () {
      expect(
        ExerciseRecord.tryFromJson({
          'weight': 'abc',
          'reps': 5,
          'oneRM': 100,
          'date': '2024-01-15T10:00:00.000',
        }),
        isNull,
      );
    });

    test('returns null for invalid date string', () {
      expect(
        ExerciseRecord.tryFromJson({
          'weight': 100,
          'reps': 5,
          'oneRM': 100,
          'date': 'hello',
        }),
        isNull,
      );
    });

    test('returns record for valid input', () {
      final result = ExerciseRecord.tryFromJson({
        'weight': 100,
        'reps': 5,
        'oneRM': 116.7,
        'date': '2024-01-15T10:00:00.000',
      });
      expect(result, isNotNull);
      expect(result!.weight, 100);
      expect(result.reps, 5);
    });
  });
}
