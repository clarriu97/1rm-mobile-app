import 'package:flutter/foundation.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../services/exercise_library_service.dart';

/// Why a custom exercise name was rejected.
enum ExerciseNameError { empty, tooLong, duplicate }

/// All exercises (built-in + custom) and which ones are shown on Home.
class ExerciseLibrary extends ChangeNotifier {
  ExerciseLibrary(
    this._service, {
    List<CustomExerciseData> custom = const [],
    Set<String> hidden = const {},
    DateTime Function() clock = DateTime.now,
  }) : _custom = List.of(custom),
       _hidden = Set.of(hidden),
       _clock = clock;

  static Future<ExerciseLibrary> load(ExerciseLibraryService service) async =>
      ExerciseLibrary(
        service,
        custom: await service.loadCustom(),
        hidden: await service.loadHidden(),
      );

  static const maxNameLength = 40;

  final ExerciseLibraryService _service;
  final List<CustomExerciseData> _custom;
  final Set<String> _hidden;
  final DateTime Function() _clock;

  /// Built-in exercises first (fixed order), then custom ones by creation.
  List<ExerciseTemplate> get all => [
    ...defaultExercises,
    for (final c in _custom)
      ExerciseTemplate(
        id: c.id,
        name: c.name,
        category: ExerciseCategory.other,
        assetPath: customExerciseIcon,
      ),
  ];

  List<ExerciseTemplate> get visible =>
      all.where((e) => !_hidden.contains(e.id)).toList();

  bool isHidden(String id) => _hidden.contains(id);

  bool isCustom(String id) => _custom.any((c) => c.id == id);

  ExerciseNameError? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return ExerciseNameError.empty;
    if (trimmed.length > maxNameLength) return ExerciseNameError.tooLong;
    final lower = trimmed.toLowerCase();
    if (all.any((e) => e.name.toLowerCase() == lower)) {
      return ExerciseNameError.duplicate;
    }
    return null;
  }

  /// Creates a custom exercise. Throws [ArgumentError] for an invalid name;
  /// call [validateName] first to show feedback.
  Future<ExerciseTemplate> addCustom(String name) async {
    final error = validateName(name);
    if (error != null) throw ArgumentError.value(name, 'name', error.name);
    var id = 'custom_${_clock().microsecondsSinceEpoch}';
    while (all.any((e) => e.id == id)) {
      id = '${id}_';
    }
    _custom.add(CustomExerciseData(id: id, name: name.trim()));
    notifyListeners();
    await _service.saveCustom(_custom);
    return all.last;
  }

  /// Hides or shows an exercise on Home. Its records are never touched.
  Future<void> setHidden(String id, {required bool hidden}) async {
    final changed = hidden ? _hidden.add(id) : _hidden.remove(id);
    if (!changed) return;
    notifyListeners();
    await _service.saveHidden(_hidden);
  }
}
