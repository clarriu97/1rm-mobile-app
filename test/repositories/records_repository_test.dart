import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/exercise.dart';
import 'package:one_rm_mobile/repositories/records_repository.dart';
import 'package:one_rm_mobile/services/storage_service.dart';

ExerciseRecord _record({
  double weight = 100,
  int reps = 5,
  double oneRM = 116.7,
  DateTime? date,
}) => ExerciseRecord(
  weight: weight,
  reps: reps,
  oneRM: oneRM,
  date: date ?? DateTime(2026, 1, 5),
);

void main() {
  group('RecordsRepository — reads', () {
    test('unknown exercise has no records, best or latest', () {
      final repo = RecordsRepository(StorageService.inMemoryForTesting());

      expect(repo.recordsFor('Back Squat'), isEmpty);
      expect(repo.bestOneRMFor('Back Squat'), isNull);
      expect(repo.latestFor('Back Squat'), isNull);
    });

    test('empty initial list is treated as no records', () {
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Back Squat': [],
      });

      expect(repo.recordsFor('Back Squat'), isEmpty);
      expect(repo.bestOneRMFor('Back Squat'), isNull);
    });

    test('bestOneRMFor returns the highest 1RM', () {
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Deadlift': [
          _record(oneRM: 180),
          _record(oneRM: 210),
          _record(oneRM: 195),
        ],
      });

      expect(repo.bestOneRMFor('Deadlift'), 210);
    });

    test('bestOneRMFor handles ties', () {
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Deadlift': [_record(oneRM: 200), _record(oneRM: 200)],
      });

      expect(repo.bestOneRMFor('Deadlift'), 200);
    });

    test('latestFor returns the most recent entry regardless of order', () {
      final newest = _record(date: DateTime(2026, 3, 15));
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Snatch': [
          _record(date: DateTime(2026, 1, 10)),
          newest,
          _record(date: DateTime(2026, 2, 10)),
        ],
      });

      expect(repo.latestFor('Snatch'), same(newest));
    });

    test('recordsFor returns an unmodifiable view', () {
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Snatch': [_record()],
      });

      expect(
        () => repo.recordsFor('Snatch').add(_record()),
        throwsUnsupportedError,
      );
    });

    test('mutating the initial map does not affect the repository', () {
      final initial = {
        'Snatch': [_record()],
      };
      final repo = RecordsRepository(
        StorageService.inMemoryForTesting(),
        initial,
      );

      initial['Snatch']!.add(_record());

      expect(repo.recordsFor('Snatch'), hasLength(1));
    });
  });

  group('RecordsRepository — add', () {
    test('adds a record and persists it immediately', () async {
      final storage = StorageService.inMemoryForTesting();
      final repo = RecordsRepository(storage);
      final record = _record();

      await repo.add('Bench Press', record);

      expect(repo.recordsFor('Bench Press'), [record]);
      expect((await storage.load())['Bench Press'], [record]);
    });

    test('notifies listeners', () async {
      final repo = RecordsRepository(StorageService.inMemoryForTesting());
      var notifications = 0;
      repo.addListener(() => notifications++);

      await repo.add('Bench Press', _record());

      expect(notifications, 1);
    });

    test('keeps records of other exercises untouched', () async {
      final squat = _record(oneRM: 150);
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Back Squat': [squat],
      });

      await repo.add('Bench Press', _record(oneRM: 100));

      expect(repo.recordsFor('Back Squat'), [squat]);
      expect(repo.bestOneRMFor('Bench Press'), 100);
    });

    test('survives an app restart with file storage', () async {
      final dir = await Directory.systemTemp.createTemp('records_repo_test_');
      addTearDown(() => dir.delete(recursive: true));

      final repo = await RecordsRepository.load(
        await StorageService.getInstanceForTesting(directory: dir),
      );
      await repo.add('Front Squat', _record(weight: 120, reps: 3, oneRM: 132));

      final reopened = await RecordsRepository.load(
        await StorageService.getInstanceForTesting(directory: dir),
      );

      final records = reopened.recordsFor('Front Squat');
      expect(records, hasLength(1));
      expect(records.single.weight, 120);
      expect(records.single.reps, 3);
      expect(records.single.oneRM, 132);
    });
  });

  group('RecordsRepository — delete', () {
    test('removes the record and persists immediately', () async {
      final storage = StorageService.inMemoryForTesting();
      final keep = _record(oneRM: 100);
      final remove = _record(oneRM: 120);
      final repo = RecordsRepository(storage, {
        'Deadlift': [keep, remove],
      });

      await repo.delete('Deadlift', remove);

      expect(repo.recordsFor('Deadlift'), [keep]);
      expect(repo.bestOneRMFor('Deadlift'), 100);
      expect((await storage.load())['Deadlift'], [keep]);
    });

    test('deleting the last record removes the exercise entry', () async {
      final storage = StorageService.inMemoryForTesting();
      final only = _record();
      final repo = RecordsRepository(storage, {
        'Deadlift': [only],
      });

      await repo.delete('Deadlift', only);

      expect(repo.recordsFor('Deadlift'), isEmpty);
      expect(repo.bestOneRMFor('Deadlift'), isNull);
      expect(await storage.load(), isNot(contains('Deadlift')));
    });

    test(
      'deleting an unknown record is a no-op without notification',
      () async {
        final storage = StorageService.inMemoryForTesting();
        final existing = _record();
        final repo = RecordsRepository(storage, {
          'Deadlift': [existing],
        });
        var notifications = 0;
        repo.addListener(() => notifications++);

        await repo.delete('Deadlift', _record());
        await repo.delete('Unknown', existing);

        expect(repo.recordsFor('Deadlift'), [existing]);
        expect(notifications, 0);
        expect(await storage.load(), isEmpty);
      },
    );

    test('deletes only the given instance when values are equal', () async {
      final first = _record();
      final second = _record();
      final repo = RecordsRepository(StorageService.inMemoryForTesting(), {
        'Deadlift': [first, second],
      });

      await repo.delete('Deadlift', second);

      expect(repo.recordsFor('Deadlift').single, same(first));
    });
  });
}
