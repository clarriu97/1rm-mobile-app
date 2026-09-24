import '../data/default_exercises.dart';
import '../models/exercise.dart';
import 'app_localizations.dart';

extension LocalizedNames on AppLocalizations {
  /// Translated name of a built-in exercise, or null for any other id.
  String? builtInExerciseName(String id) => switch (id) {
    'back_squat' => exerciseBackSquat,
    'front_squat' => exerciseFrontSquat,
    'overhead_squat' => exerciseOverheadSquat,
    'box_squat' => exerciseBoxSquat,
    'leg_press' => exerciseLegPress,
    'deadlift' => exerciseDeadlift,
    'sumo_deadlift' => exerciseSumoDeadlift,
    'romanian_deadlift' => exerciseRomanianDeadlift,
    'good_morning' => exerciseGoodMorning,
    'hip_thrust' => exerciseHipThrust,
    'bench_press' => exerciseBenchPress,
    'incline_bench_press' => exerciseInclineBenchPress,
    'close_grip_bench_press' => exerciseCloseGripBenchPress,
    'weighted_dip' => exerciseWeightedDip,
    'overhead_press' => exerciseOverheadPress,
    'push_press' => exercisePushPress,
    'push_jerk' => exercisePushJerk,
    'split_jerk' => exerciseSplitJerk,
    'barbell_row' => exerciseBarbellRow,
    'pendlay_row' => exercisePendlayRow,
    'weighted_pull_up' => exerciseWeightedPullUp,
    'power_clean' => exercisePowerClean,
    'squat_clean' => exerciseSquatClean,
    'hang_power_clean' => exerciseHangPowerClean,
    'hang_squat_clean' => exerciseHangSquatClean,
    'clean_and_jerk' => exerciseCleanAndJerk,
    'thruster' => exerciseThruster,
    'cluster' => exerciseCluster,
    'sumo_deadlift_high_pull' => exerciseSumoDeadliftHighPull,
    'snatch' => exerciseSnatch,
    'power_snatch' => exercisePowerSnatch,
    'hang_power_snatch' => exerciseHangPowerSnatch,
    'hang_squat_snatch' => exerciseHangSquatSnatch,
    'snatch_balance' => exerciseSnatchBalance,
    _ => null,
  };

  /// What the user sees: the translation of a built-in exercise, or the name
  /// they typed for a custom one.
  String exerciseName(ExerciseTemplate exercise) =>
      builtInExerciseName(exercise.id) ?? exercise.name;

  String categoryName(ExerciseCategory category) => switch (category) {
    ExerciseCategory.squat => categorySquat,
    ExerciseCategory.hinge => categoryHinge,
    ExerciseCategory.bench => categoryBench,
    ExerciseCategory.overhead => categoryOverhead,
    ExerciseCategory.pull => categoryPull,
    ExerciseCategory.clean => categoryClean,
    ExerciseCategory.snatch => categorySnatch,
    ExerciseCategory.custom => categoryCustom,
  };
}
