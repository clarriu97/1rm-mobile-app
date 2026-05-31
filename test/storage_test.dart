import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/services/storage_service.dart';

final _fixedDate = DateTime(2024, 1, 15, 10);
final _record = ExerciseRecord(
  weight: 100,
  reps: 5,
  oneRM: 116.7,
  date: _fixedDate,
);

void main() {
  group('StorageService — happy path', () {
    test('saves and loads an empty map', () async {
      final storage = await StorageService.getInstanceForTesting();
      await storage.save({});
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('saves and loads records', () async {
      final storage = await StorageService.getInstanceForTesting();
      await storage.save({
        'Back Squat': [_record],
      });
      final loaded = await storage.load();

      expect(loaded.length, 1);
      expect(loaded['Back Squat']!.length, 1);
      expect(loaded['Back Squat']!.first.weight, 100);
      expect(loaded['Back Squat']!.first.reps, 5);
      expect(loaded['Back Squat']!.first.date, _fixedDate);
    });

    test('preserves multiple exercises', () async {
      final storage = await StorageService.getInstanceForTesting();
      await storage.save({
        'Bench Press': [
          ExerciseRecord(weight: 80, reps: 8, oneRM: 101.3, date: _fixedDate),
        ],
        'Deadlift': [
          ExerciseRecord(weight: 200, reps: 3, oneRM: 220, date: _fixedDate),
        ],
      });
      final loaded = await storage.load();

      expect(loaded.length, 2);
      expect(loaded.containsKey('Bench Press'), isTrue);
      expect(loaded.containsKey('Deadlift'), isTrue);
    });

    test('overwrites previous data on save', () async {
      final storage = await StorageService.getInstanceForTesting();
      await storage.save({
        'Squat': [_record],
      });
      await storage.save({
        'Deadlift': [_record],
      });
      final loaded = await storage.load();

      expect(loaded.length, 1);
      expect(loaded.containsKey('Deadlift'), isTrue);
    });
  });

  group('StorageService — file states', () {
    test('returns empty when file does not exist', () async {
      final storage = await StorageService.getInstanceForTesting(empty: true);
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('recovers from empty file content', () async {
      // Create a directory with a manually written empty file
      final dir = await Directory.systemTemp.createTemp('empty_file_');
      File('${dir.path}/records.json').writeAsStringSync('');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('recovers from whitespace-only file', () async {
      final dir = await Directory.systemTemp.createTemp('whitespace_');
      File('${dir.path}/records.json').writeAsStringSync('   \n\n   ');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });
  });

  group('StorageService — corrupted JSON', () {
    test('recovers from malformed JSON', () async {
      final dir = await Directory.systemTemp.createTemp('bad_json_');
      File('${dir.path}/records.json').writeAsStringSync('{not valid json');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('recovers when root is an array instead of object', () async {
      final dir = await Directory.systemTemp.createTemp('array_root_');
      File('${dir.path}/records.json').writeAsStringSync('[{"weight": 100}]');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('recovers when root is a primitive', () async {
      final dir = await Directory.systemTemp.createTemp('primitive_');
      File('${dir.path}/records.json').writeAsStringSync('"just a string"');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();
      expect(loaded, isEmpty);
    });

    test('skips entries whose value is not a list', () async {
      final dir = await Directory.systemTemp.createTemp('not_list_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [{"weight": 100, "reps": 5, "oneRM": 116.7, "date": "2024-01-15T10:00:00.000"}],
          "Deadlift": "not a list"
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded.length, 1);
      expect(loaded.containsKey('Squat'), isTrue);
      expect(loaded.containsKey('Deadlift'), isFalse);
    });
  });

  group('ExerciseRecord — corrupted records', () {
    test('skips records with missing fields', () async {
      final dir = await Directory.systemTemp.createTemp('missing_fields_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [
            {"weight": 100, "oneRM": 116.7, "date": "2024-01-15T10:00:00.000"}
          ]
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded, isEmpty);
    });

    test('skips records with wrong field types', () async {
      final dir = await Directory.systemTemp.createTemp('wrong_types_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [
            {"weight": "not a number", "reps": 5, "oneRM": 116.7, "date": "2024-01-15T10:00:00.000"}
          ]
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded, isEmpty);
    });

    test('skips records with null fields', () async {
      final dir = await Directory.systemTemp.createTemp('null_fields_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [
            {"weight": null, "reps": 5, "oneRM": 116.7, "date": "2024-01-15T10:00:00.000"}
          ]
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded, isEmpty);
    });

    test('skips records with invalid date', () async {
      final dir = await Directory.systemTemp.createTemp('bad_date_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [
            {"weight": 100, "reps": 5, "oneRM": 116.7, "date": "not-a-date"}
          ]
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded, isEmpty);
    });

    test('skips items that are not maps inside a record list', () async {
      final dir = await Directory.systemTemp.createTemp('not_map_in_list_');
      File('${dir.path}/records.json').writeAsStringSync('''
        {
          "Squat": [
            {"weight": 100, "reps": 5, "oneRM": 116.7, "date": "2024-01-15T10:00:00.000"},
            "not a map",
            42
          ]
        }
      ''');
      final storage = await StorageService.getInstanceForTesting(
        directory: dir,
      );
      final loaded = await storage.load();

      expect(loaded.length, 1);
      expect(loaded['Squat']!.length, 1);
      expect(loaded['Squat']!.first.weight, 100);
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
