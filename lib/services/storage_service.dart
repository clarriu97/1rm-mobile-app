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
    bool empty = false,
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

  @override
  Future<Map<String, List<ExerciseRecord>>> load() async {
    try {
      if (!await _file.exists()) return {};
      final contents = await _file.readAsString();
      if (contents.trim().isEmpty) return {};

      final decoded = json.decode(contents);
      // Root must be a JSON object
      if (decoded is! Map<String, dynamic>) return {};

      if (!decoded.containsKey('schemaVersion')) {
        // v1: exercise display name → records
        return _migrateV1Keys(_parseRecords(decoded));
      }
      final records = decoded['records'];
      if (records is! Map<String, dynamic>) return {};
      return _parseRecords(records);
    } catch (_) {
      // Any error during read/parse → start fresh
      return {};
    }
  }

  @override
  Future<void> save(Map<String, List<ExerciseRecord>> records) async {
    try {
      final data = {
        'schemaVersion': StorageService.schemaVersion,
        'records': records.map(
          (key, value) => MapEntry(key, value.map((r) => r.toJson()).toList()),
        ),
      };
      await _file.writeAsString(json.encode(data));
    } catch (_) {
      // Silent fail — no data is better than a crash
    }
  }

  static Map<String, List<ExerciseRecord>> _parseRecords(
    Map<String, dynamic> raw,
  ) {
    final result = <String, List<ExerciseRecord>>{};
    for (final entry in raw.entries) {
      // Value must be a list
      if (entry.value is! List) continue;

      final rawList = entry.value as List;
      final records = <ExerciseRecord>[];
      for (final item in rawList) {
        // Each item must be a map with valid fields
        if (item is! Map<String, dynamic>) continue;
        final record = ExerciseRecord.tryFromJson(item);
        if (record == null) continue;
        records.add(record);
      }

      if (records.isNotEmpty) {
        result[entry.key] = records;
      }
    }
    return result;
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
