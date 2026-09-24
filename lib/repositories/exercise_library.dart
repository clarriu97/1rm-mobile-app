import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../services/exercise_library_service.dart';

/// Why a custom exercise name was rejected.
enum ExerciseNameError { empty, tooLong, duplicate }

/// A deleted custom exercise with everything [ExerciseLibrary.restoreCustom]
/// needs to put it back where it was.
typedef RemovedCustomExercise = ({
  CustomExerciseData exercise,
  int index,
  bool hidden,
  bool shown,
});

/// All exercises (built-in + custom) and which ones are shown on Home.
///
/// Visibility = the exercise's default ([ExerciseTemplate.defaultVisible],
/// always true for custom ones) unless the user explicitly showed or hid it.
class ExerciseLibrary extends ChangeNotifier {
  ExerciseLibrary(
    this._service, {
    List<CustomExerciseData> custom = const [],
    Set<String> hidden = const {},
    Set<String> shown = const {},
    DateTime Function() clock = DateTime.now,
  }) : _custom = List.of(custom),
       _hidden = Set.of(hidden),
       _shown = Set.of(shown),
       _clock = clock;

  static Future<ExerciseLibrary> load(ExerciseLibraryService service) async =>
      ExerciseLibrary(
        service,
        custom: await service.loadCustom(),
        hidden: await service.loadHidden(),
        shown: await service.loadShown(),
      );

  static const maxNameLength = 40;

  final ExerciseLibraryService _service;
  final List<CustomExerciseData> _custom;
  final Set<String> _hidden;
  final Set<String> _shown;
  final DateTime Function() _clock;

  /// Built-in exercises first (fixed order), then custom ones by creation.
  List<ExerciseTemplate> get all => [
    ...defaultExercises,
    for (final c in _custom)
      ExerciseTemplate(
        id: c.id,
        name: c.name,
        category: ExerciseCategory.custom,
        assetPath: customExerciseIcon,
        defaultVisible: true,
      ),
  ];

  List<ExerciseTemplate> get visible =>
      all.where((e) => !_isHidden(e)).toList();

  bool isHidden(String id) {
    final template = all.where((e) => e.id == id).firstOrNull;
    return template == null ? _hidden.contains(id) : _isHidden(template);
  }

  bool _isHidden(ExerciseTemplate e) =>
      _hidden.contains(e.id) || (!_shown.contains(e.id) && !e.defaultVisible);

  bool isCustom(String id) => _custom.any((c) => c.id == id);

  /// [localizedNames] are the names shown in the user's language, which a
  /// new exercise must not repeat either. When renaming, [renaming] is the
  /// exercise's id: its own current name is not a duplicate.
  ExerciseNameError? validateName(
    String name, {
    Iterable<String> localizedNames = const [],
    String? renaming,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return ExerciseNameError.empty;
    if (trimmed.length > maxNameLength) return ExerciseNameError.tooLong;
    final lower = trimmed.toLowerCase();
    final taken = [
      for (final e in all)
        if (e.id != renaming) e.name,
      ...localizedNames,
    ];
    if (taken.any((n) => n.toLowerCase() == lower)) {
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

  /// Renames custom exercise [id]; its id, and so its records, stay the
  /// same. Throws [ArgumentError] for an invalid name or a non-custom id.
  Future<void> renameCustom(String id, String name) async {
    final index = _customIndex(id);
    final error = validateName(name, renaming: id);
    if (error != null) throw ArgumentError.value(name, 'name', error.name);
    _custom[index] = CustomExerciseData(id: id, name: name.trim());
    notifyListeners();
    await _service.saveCustom(_custom);
  }

  /// Deletes custom exercise [id] from the library. Its records are the
  /// caller's to delete. Throws [ArgumentError] for a non-custom id.
  Future<RemovedCustomExercise> removeCustom(String id) async {
    final index = _customIndex(id);
    final removed = (
      exercise: _custom.removeAt(index),
      index: index,
      hidden: _hidden.remove(id),
      shown: _shown.remove(id),
    );
    notifyListeners();
    await _service.saveCustom(_custom);
    await _persistVisibility();
    return removed;
  }

  /// Undoes [removeCustom]: same place, name and visibility.
  Future<void> restoreCustom(RemovedCustomExercise removed) async {
    if (isCustom(removed.exercise.id)) return;
    _custom.insert(math.min(removed.index, _custom.length), removed.exercise);
    if (removed.hidden) _hidden.add(removed.exercise.id);
    if (removed.shown) _shown.add(removed.exercise.id);
    notifyListeners();
    await _service.saveCustom(_custom);
    await _persistVisibility();
  }

  int _customIndex(String id) {
    final index = _custom.indexWhere((c) => c.id == id);
    if (index < 0) throw ArgumentError.value(id, 'id', 'not a custom exercise');
    return index;
  }

  /// Hides or shows an exercise on Home. Its records are never touched.
  Future<void> setHidden(String id, {required bool hidden}) async {
    if (isHidden(id) == hidden) return;
    if (hidden) {
      _hidden.add(id);
      _shown.remove(id);
    } else {
      _shown.add(id);
      _hidden.remove(id);
    }
    notifyListeners();
    await _persistVisibility();
  }

  /// Makes exactly [ids] visible (onboarding picker). Only exercises whose
  /// visibility actually changes get an explicit override, so untouched ones
  /// keep following their defaults.
  Future<void> setVisibleExactly(Set<String> ids) async {
    var changed = false;
    for (final e in all) {
      final show = ids.contains(e.id);
      if (_isHidden(e) != show) continue;
      changed = true;
      if (show) {
        _shown.add(e.id);
        _hidden.remove(e.id);
      } else {
        _hidden.add(e.id);
        _shown.remove(e.id);
      }
    }
    if (!changed) return;
    notifyListeners();
    await _persistVisibility();
  }

  Future<void> _persistVisibility() async {
    await _service.saveHidden(_hidden);
    await _service.saveShown(_shown);
  }
}
