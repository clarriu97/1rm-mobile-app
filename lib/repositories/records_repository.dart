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

  /// Adds [record] and completes with `true` when it is a new personal
  /// record: strictly better than the previous best. The first entry of an
  /// exercise is not a PR — there is nothing to beat yet.
  Future<bool> add(String exercise, ExerciseRecord record) async {
    final previousBest = bestOneRMFor(exercise);
    (_records[exercise] ??= []).add(record);
    notifyListeners();
    await _storage.save(_records);
    return previousBest != null && record.oneRM > previousBest + _epsilon;
  }

  /// Entries that beat every earlier entry (by date) when they were logged.
  /// Ties don't count and neither does the very first entry.
  Set<ExerciseRecord> personalRecordsFor(String exercise) {
    final chronological = List.of(
      _records[exercise] ?? const <ExerciseRecord>[],
    )..sort((a, b) => a.date.compareTo(b.date));
    final prs = Set<ExerciseRecord>.identity();
    double? best;
    for (final record in chronological) {
      if (best != null && record.oneRM > best + _epsilon) prs.add(record);
      if (best == null || record.oneRM > best) best = record.oneRM;
    }
    return prs;
  }

  /// Tolerance for float noise from unit conversions.
  static const _epsilon = 1e-9;

  /// Replaces [original] (by identity) with [updated]. No-op if not found.
  Future<void> update(
    String exercise,
    ExerciseRecord original,
    ExerciseRecord updated,
  ) async {
    final records = _records[exercise];
    final index = records?.indexWhere((r) => identical(r, original)) ?? -1;
    if (index < 0) return;
    records![index] = updated;
    notifyListeners();
    await _storage.save(_records);
  }

  /// Deletes every record of [exercise] and returns them, for [restoreAll].
  Future<List<ExerciseRecord>> deleteAll(String exercise) async {
    final removed = _records.remove(exercise);
    if (removed == null) return const [];
    notifyListeners();
    await _storage.save(_records);
    return removed;
  }

  /// Puts back records removed by [deleteAll], next to any added since.
  Future<void> restoreAll(String exercise, List<ExerciseRecord> records) async {
    if (records.isEmpty) return;
    (_records[exercise] ??= []).addAll(records);
    notifyListeners();
    await _storage.save(_records);
  }

  Future<void> delete(String exercise, ExerciseRecord record) async {
    final records = _records[exercise];
    if (records == null || !records.remove(record)) return;
    if (records.isEmpty) _records.remove(exercise);
    notifyListeners();
    await _storage.save(_records);
  }
}
