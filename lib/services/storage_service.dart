import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/exercise.dart';

class StorageService {
  StorageService._(this._file);

  final File _file;

  static Future<StorageService> getInstance() async {
    final dir = await getApplicationDocumentsDirectory();
    return StorageService._(File('${dir.path}/records.json'));
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
    return StorageService._(file);
  }

  Future<Map<String, List<ExerciseRecord>>> load() async {
    try {
      if (!await _file.exists()) return {};
      final contents = await _file.readAsString();
      if (contents.trim().isEmpty) return {};

      final decoded = json.decode(contents);
      // Root must be a JSON object
      if (decoded is! Map<String, dynamic>) return {};

      final result = <String, List<ExerciseRecord>>{};
      for (final entry in decoded.entries) {
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
    } catch (_) {
      // Any error during read/parse → start fresh
      return {};
    }
  }

  Future<void> save(Map<String, List<ExerciseRecord>> records) async {
    try {
      final data = records.map(
        (key, value) => MapEntry(key, value.map((r) => r.toJson()).toList()),
      );
      await _file.writeAsString(json.encode(data));
    } catch (_) {
      // Silent fail — no data is better than a crash
    }
  }
}
