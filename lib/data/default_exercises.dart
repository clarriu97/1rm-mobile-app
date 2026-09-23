import '../models/exercise.dart';

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
    this.defaultVisible = false,
  });

  /// Stable storage key. Never change it once shipped.
  final String id;
  final String name;
  final ExerciseCategory category;
  final String assetPath;

  /// Shown on Home until the user decides otherwise.
  final bool defaultVisible;
}

/// Built-in lifts, grouped by family in [ExerciseCategory] order.
/// Ids are storage keys: never change one once shipped.
const List<ExerciseTemplate> defaultExercises = [
  // Squat
  ExerciseTemplate(
    id: 'back_squat',
    name: 'Back Squat',
    category: ExerciseCategory.squat,
    assetPath: 'assets/icons/back_squat.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'front_squat',
    name: 'Front Squat',
    category: ExerciseCategory.squat,
    assetPath: 'assets/icons/front_squat.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'overhead_squat',
    name: 'Overhead Squat',
    category: ExerciseCategory.squat,
    assetPath: 'assets/icons/overhead_squat.svg',
  ),
  ExerciseTemplate(
    id: 'box_squat',
    name: 'Box Squat',
    category: ExerciseCategory.squat,
    assetPath: 'assets/icons/box_squat.svg',
  ),
  ExerciseTemplate(
    id: 'leg_press',
    name: 'Leg Press',
    category: ExerciseCategory.squat,
    assetPath: 'assets/icons/leg_press.svg',
  ),
  // Hinge
  ExerciseTemplate(
    id: 'deadlift',
    name: 'Deadlift',
    category: ExerciseCategory.hinge,
    assetPath: 'assets/icons/deadlift.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'sumo_deadlift',
    name: 'Sumo Deadlift',
    category: ExerciseCategory.hinge,
    assetPath: 'assets/icons/sumo_deadlift.svg',
  ),
  ExerciseTemplate(
    id: 'romanian_deadlift',
    name: 'Romanian Deadlift',
    category: ExerciseCategory.hinge,
    assetPath: 'assets/icons/romanian_deadlift.svg',
  ),
  ExerciseTemplate(
    id: 'good_morning',
    name: 'Good Morning',
    category: ExerciseCategory.hinge,
    assetPath: 'assets/icons/good_morning.svg',
  ),
  ExerciseTemplate(
    id: 'hip_thrust',
    name: 'Hip Thrust',
    category: ExerciseCategory.hinge,
    assetPath: 'assets/icons/hip_thrust.svg',
  ),
  // Bench
  ExerciseTemplate(
    id: 'bench_press',
    name: 'Bench Press',
    category: ExerciseCategory.bench,
    assetPath: 'assets/icons/bench_press.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'incline_bench_press',
    name: 'Incline Bench Press',
    category: ExerciseCategory.bench,
    assetPath: 'assets/icons/incline_bench_press.svg',
  ),
  ExerciseTemplate(
    id: 'close_grip_bench_press',
    name: 'Close-Grip Bench Press',
    category: ExerciseCategory.bench,
    assetPath: 'assets/icons/close_grip_bench_press.svg',
  ),
  ExerciseTemplate(
    id: 'weighted_dip',
    name: 'Weighted Dip',
    category: ExerciseCategory.bench,
    assetPath: 'assets/icons/weighted_dip.svg',
  ),
  // Overhead
  ExerciseTemplate(
    id: 'overhead_press',
    name: 'Overhead Press',
    category: ExerciseCategory.overhead,
    assetPath: 'assets/icons/overhead_press.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'push_press',
    name: 'Push Press',
    category: ExerciseCategory.overhead,
    assetPath: 'assets/icons/push_press.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'push_jerk',
    name: 'Push Jerk',
    category: ExerciseCategory.overhead,
    assetPath: 'assets/icons/push_jerk.svg',
  ),
  ExerciseTemplate(
    id: 'split_jerk',
    name: 'Split Jerk',
    category: ExerciseCategory.overhead,
    assetPath: 'assets/icons/split_jerk.svg',
  ),
  // Pull
  ExerciseTemplate(
    id: 'barbell_row',
    name: 'Barbell Row',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/barbell_row.svg',
  ),
  ExerciseTemplate(
    id: 'pendlay_row',
    name: 'Pendlay Row',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/pendlay_row.svg',
  ),
  ExerciseTemplate(
    id: 'weighted_pull_up',
    name: 'Weighted Pull-Up',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/weighted_pull_up.svg',
  ),
  // Clean
  ExerciseTemplate(
    id: 'power_clean',
    name: 'Power Clean',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/power_clean.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'squat_clean',
    name: 'Squat Clean',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/squat_clean.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'hang_power_clean',
    name: 'Hang Power Clean',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/hang_power_clean.svg',
  ),
  ExerciseTemplate(
    id: 'hang_squat_clean',
    name: 'Hang Squat Clean',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/hang_squat_clean.svg',
  ),
  ExerciseTemplate(
    id: 'clean_and_jerk',
    name: 'Clean & Jerk',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/clean_and_jerk.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'thruster',
    name: 'Thruster',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/thruster.svg',
  ),
  ExerciseTemplate(
    id: 'cluster',
    name: 'Cluster',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/cluster.svg',
  ),
  ExerciseTemplate(
    id: 'sumo_deadlift_high_pull',
    name: 'Sumo Deadlift High Pull',
    category: ExerciseCategory.clean,
    assetPath: 'assets/icons/sumo_deadlift_high_pull.svg',
  ),
  // Snatch
  ExerciseTemplate(
    id: 'snatch',
    name: 'Snatch',
    category: ExerciseCategory.snatch,
    assetPath: 'assets/icons/snatch.svg',
    defaultVisible: true,
  ),
  ExerciseTemplate(
    id: 'power_snatch',
    name: 'Power Snatch',
    category: ExerciseCategory.snatch,
    assetPath: 'assets/icons/power_snatch.svg',
  ),
  ExerciseTemplate(
    id: 'hang_power_snatch',
    name: 'Hang Power Snatch',
    category: ExerciseCategory.snatch,
    assetPath: 'assets/icons/hang_power_snatch.svg',
  ),
  ExerciseTemplate(
    id: 'hang_squat_snatch',
    name: 'Hang Squat Snatch',
    category: ExerciseCategory.snatch,
    assetPath: 'assets/icons/hang_squat_snatch.svg',
  ),
  ExerciseTemplate(
    id: 'snatch_balance',
    name: 'Snatch Balance',
    category: ExerciseCategory.snatch,
    assetPath: 'assets/icons/snatch_balance.svg',
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

/// [exercises] grouped by family, families in [ExerciseCategory] order and
/// exercises in their original order. Empty families are left out.
List<(ExerciseCategory, List<ExerciseTemplate>)> groupByCategory(
  Iterable<ExerciseTemplate> exercises,
) => [
  for (final category in ExerciseCategory.values)
    if (exercises.where((e) => e.category == category).toList() case final group
        when group.isNotEmpty)
      (category, group),
];
