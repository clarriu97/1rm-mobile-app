import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';

abstract class StorageService {
  /// Version written to the records file. Bump it with every format change
  /// and add a migration for the previous version.
  static const int schemaVersion = 2;

  Future<Map<String, List<ExerciseRecord>>> load();
  Future<void> save(Map<String, List<ExerciseRecord>> records);

  static Future<StorageService> getInstance() async {
    final dir = await getApplicationDocumentsDirectory();
    return _FileStorageService(File('${dir.path}/records.json'));
  }

  /// Creates an instance backed by a test directory.
  /// Not for production use.
  static Future<StorageService> getInstanceForTesting({
    Directory? directory,
  }) async {
    final dir =
        directory ?? await Directory.systemTemp.createTemp('storage_test_');
    final file = File('${dir.path}/records.json');
    return _FileStorageService(file);
  }

  /// In-memory instance for widget tests, where real file I/O does not
  /// complete inside the fake async zone.
  static StorageService inMemoryForTesting() => _InMemoryStorageService();
}

class _FileStorageService implements StorageService {
  _FileStorageService(this._file);

  final File _file;

  File get _tempFile => File('${_file.path}.tmp');

  @override
  Future<Map<String, List<ExerciseRecord>>> load() async {
    if (!await _file.exists()) return {};
    try {
      final contents = await _file.readAsString();
      if (contents.trim().isEmpty) return {};

      final parsed = _decode(json.decode(contents));
      if (parsed == null || parsed.lossy) await _backup();
      return parsed?.records ?? {};
    } catch (_) {
      // Unreadable or malformed: keep a copy so the next save can't destroy it.
      await _backup();
      return {};
    }
  }

  /// Writes to a temp file and renames it over the real one, so an
  /// interrupted write never leaves a half-written records file.
  /// Errors propagate to the caller.
  @override
  Future<void> save(Map<String, List<ExerciseRecord>> records) async {
    final data = {
      'schemaVersion': StorageService.schemaVersion,
      'records': records.map(
        (key, value) => MapEntry(key, value.map((r) => r.toJson()).toList()),
      ),
    };
    await _tempFile.writeAsString(json.encode(data), flush: true);
    await _tempFile.rename(_file.path);
  }

  Future<void> _backup() async {
    try {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      await _file.copy('${_file.parent.path}/records.corrupt-$stamp.json');
    } catch (_) {
      // Best effort: nothing more we can do if the copy fails too.
    }
  }

  /// Returns null when the file structure is unusable; `lossy` is true when
  /// some entries or records had to be skipped.
  static ({Map<String, List<ExerciseRecord>> records, bool lossy})? _decode(
    Object? decoded,
  ) {
    // Root must be a JSON object
    if (decoded is! Map<String, dynamic>) return null;

    if (!decoded.containsKey('schemaVersion')) {
      // v1: exercise display name → records
      final parsed = _parseRecords(decoded);
      return (records: _migrateV1Keys(parsed.records), lossy: parsed.lossy);
    }
    final records = decoded['records'];
    if (records is! Map<String, dynamic>) return null;
    return _parseRecords(records);
  }

  static ({Map<String, List<ExerciseRecord>> records, bool lossy})
  _parseRecords(Map<String, dynamic> raw) {
    final result = <String, List<ExerciseRecord>>{};
    var lossy = false;
    for (final entry in raw.entries) {
      // Value must be a list
      if (entry.value is! List) {
        lossy = true;
        continue;
      }

      final rawList = entry.value as List;
      final records = <ExerciseRecord>[];
      for (final item in rawList) {
        // Each item must be a map with valid fields
        final record = item is Map<String, dynamic>
            ? ExerciseRecord.tryFromJson(item)
            : null;
        if (record == null) {
          lossy = true;
          continue;
        }
        records.add(record);
      }

      if (records.isNotEmpty) {
        result[entry.key] = records;
      }
    }
    return (records: result, lossy: lossy);
  }

  /// Maps legacy display-name keys to stable ids. Unknown keys are kept as-is
  /// so no data is ever dropped; records for the same id are merged.
  static Map<String, List<ExerciseRecord>> _migrateV1Keys(
    Map<String, List<ExerciseRecord>> legacy,
  ) {
    final result = <String, List<ExerciseRecord>>{};
    for (final entry in legacy.entries) {
      final id = legacyExerciseIds[entry.key] ?? entry.key;
      (result[id] ??= []).addAll(entry.value);
    }
    return result;
  }
}

class _InMemoryStorageService implements StorageService {
  Map<String, List<ExerciseRecord>> _data = {};

  @override
  Future<Map<String, List<ExerciseRecord>>> load() async => _copy(_data);

  @override
  Future<void> save(Map<String, List<ExerciseRecord>> records) async {
    _data = _copy(records);
  }

  static Map<String, List<ExerciseRecord>> _copy(
    Map<String, List<ExerciseRecord>> source,
  ) => {for (final entry in source.entries) entry.key: List.of(entry.value)};
}
