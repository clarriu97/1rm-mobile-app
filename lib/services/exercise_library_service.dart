import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A user-created exercise as stored on disk.
class CustomExerciseData {
  const CustomExerciseData({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static CustomExerciseData? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String || id.isEmpty || name.isEmpty) {
      return null;
    }
    return CustomExerciseData(id: id, name: name);
  }
}

/// Persists the user's exercise library choices: custom exercises and which
/// exercises are hidden from Home.
abstract class ExerciseLibraryService {
  Future<List<CustomExerciseData>> loadCustom();
  Future<void> saveCustom(List<CustomExerciseData> exercises);
  Future<Set<String>> loadHidden();
  Future<void> saveHidden(Set<String> ids);

  static Future<ExerciseLibraryService> getInstance() async =>
      _PrefsExerciseLibraryService(await SharedPreferences.getInstance());

  static ExerciseLibraryService forTesting({
    List<CustomExerciseData> custom = const [],
    Set<String> hidden = const {},
  }) => _FakeExerciseLibraryService(custom, hidden);
}

class _PrefsExerciseLibraryService implements ExerciseLibraryService {
  _PrefsExerciseLibraryService(this._prefs);

  final SharedPreferences _prefs;
  static const _customKey = 'custom_exercises';
  static const _hiddenKey = 'hidden_exercises';

  @override
  Future<List<CustomExerciseData>> loadCustom() async {
    final raw = _prefs.getString(_customKey);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is! List) return [];
      return decoded
          .map(CustomExerciseData.tryFromJson)
          .whereType<CustomExerciseData>()
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> saveCustom(List<CustomExerciseData> exercises) =>
      _prefs.setString(
        _customKey,
        json.encode([for (final e in exercises) e.toJson()]),
      );

  @override
  Future<Set<String>> loadHidden() async =>
      (_prefs.getStringList(_hiddenKey) ?? const []).toSet();

  @override
  Future<void> saveHidden(Set<String> ids) =>
      _prefs.setStringList(_hiddenKey, ids.toList()..sort());
}

class _FakeExerciseLibraryService implements ExerciseLibraryService {
  _FakeExerciseLibraryService(
    List<CustomExerciseData> custom,
    Set<String> hidden,
  ) : _custom = List.of(custom),
      _hidden = Set.of(hidden);

  List<CustomExerciseData> _custom;
  Set<String> _hidden;

  @override
  Future<List<CustomExerciseData>> loadCustom() async => List.of(_custom);

  @override
  Future<void> saveCustom(List<CustomExerciseData> exercises) async =>
      _custom = List.of(exercises);

  @override
  Future<Set<String>> loadHidden() async => Set.of(_hidden);

  @override
  Future<void> saveHidden(Set<String> ids) async => _hidden = Set.of(ids);
}
