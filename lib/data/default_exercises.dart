import '../models/exercise.dart';

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.name,
    required this.category,
    required this.assetPath,
  });

  final String name;
  final ExerciseCategory category;
  final String assetPath;
}

const List<ExerciseTemplate> defaultExercises = [
  ExerciseTemplate(
    name: 'Back Squat',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/back_squat.svg',
  ),
  ExerciseTemplate(
    name: 'Front Squat',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/front_squat.svg',
  ),
  ExerciseTemplate(
    name: 'Bench Press',
    category: ExerciseCategory.push,
    assetPath: 'assets/icons/bench_press.svg',
  ),
  ExerciseTemplate(
    name: 'Deadlift',
    category: ExerciseCategory.pull,
    assetPath: 'assets/icons/deadlift.svg',
  ),
  ExerciseTemplate(
    name: 'Power Clean',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/power_clean.svg',
  ),
  ExerciseTemplate(
    name: 'Snatch',
    category: ExerciseCategory.legs,
    assetPath: 'assets/icons/snatch.svg',
  ),
];
