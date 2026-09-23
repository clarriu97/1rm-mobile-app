import '../models/exercise.dart';

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
  });

  /// Stable storage key. Never change it once shipped.
  final String id;
  final String name;
  final ExerciseCategory category;
  final String assetPath;
}

/// Built-in lifts, grouped by family: squats, presses, pulls, Olympic.
const List<ExerciseTemplate> defaultExercises = [
  ExerciseTemplate(
    id: 'back_squat',
    name: 'Back Squat',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/back_squat.svg',
  ),
  ExerciseTemplate(
    id: 'front_squat',
    name: 'Front Squat',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/front_squat.svg',
  ),
  ExerciseTemplate(
    id: 'bench_press',
    name: 'Bench Press',
    category: ExerciseCategory.push,
    assetPath: 'assets/icons/bench_press.svg',
  ),
  ExerciseTemplate(
    id: 'overhead_press',
    name: 'Overhead Press',
    category: ExerciseCategory.push,
    assetPath: 'assets/icons/overhead_press.svg',
  ),
  ExerciseTemplate(
    id: 'push_press',
    name: 'Push Press',
    category: ExerciseCategory.push,
    assetPath: 'assets/icons/push_press.svg',
  ),
  ExerciseTemplate(
    id: 'deadlift',
    name: 'Deadlift',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/deadlift.svg',
  ),
  ExerciseTemplate(
    id: 'barbell_row',
    name: 'Barbell Row',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/barbell_row.svg',
  ),
  ExerciseTemplate(
    id: 'power_clean',
    name: 'Power Clean',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/power_clean.svg',
  ),
  ExerciseTemplate(
    id: 'clean_and_jerk',
    name: 'Clean & Jerk',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/clean_and_jerk.svg',
  ),
  ExerciseTemplate(
    id: 'snatch',
    name: 'Snatch',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/snatch.svg',
  ),
];

/// Icon for user-created exercises.
const String customExerciseIcon = 'assets/icons/barbell.svg';

/// Storage keys used before schema v2, when records were keyed by the
/// English display name. Used only to migrate old files.
const Map<String, String> legacyExerciseIds = {
  'Back Squat': 'back_squat',
  'Front Squat': 'front_squat',
  'Bench Press': 'bench_press',
  'Deadlift': 'deadlift',
  'Power Clean': 'power_clean',
  'Snatch': 'snatch',
};
