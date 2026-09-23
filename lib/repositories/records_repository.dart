import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';

/// Single source of truth for exercise records. Every mutation is persisted
/// immediately, so no screen needs to hand data back to another one.
///
/// If saving fails, the change stays in memory (and is written with the next
/// successful save) and the error is rethrown so the UI can tell the user.
class RecordsRepository extends ChangeNotifier {
  RecordsRepository(
    this._storage, [
    Map<String, List<ExerciseRecord>> initialRecords = const {},
  ]) : _records = {
         for (final entry in initialRecords.entries)
           if (entry.value.isNotEmpty) entry.key: List.of(entry.value),
       };

  static Future<RecordsRepository> load(StorageService storage) async =>
      RecordsRepository(storage, await storage.load());

  final StorageService _storage;
  final Map<String, List<ExerciseRecord>> _records;

  List<ExerciseRecord> recordsFor(String exercise) =>
      List.unmodifiable(_records[exercise] ?? const <ExerciseRecord>[]);

  double? bestOneRMFor(String exercise) {
    final records = _records[exercise];
    if (records == null || records.isEmpty) return null;
    return records.map((r) => r.oneRM).reduce((a, b) => a > b ? a : b);
  }

  ExerciseRecord? latestFor(String exercise) {
    final records = _records[exercise];
    if (records == null || records.isEmpty) return null;
    return records.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  Future<void> add(String exercise, ExerciseRecord record) {
    (_records[exercise] ??= []).add(record);
    notifyListeners();
    return _storage.save(_records);
  }

  Future<void> delete(String exercise, ExerciseRecord record) async {
    final records = _records[exercise];
    if (records == null || !records.remove(record)) return;
    if (records.isEmpty) _records.remove(exercise);
    notifyListeners();
    await _storage.save(_records);
  }
}
