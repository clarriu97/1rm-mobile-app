enum ExerciseCategory {
  push,
  pull,
  legs,
  core,
  other;

  String get displayName {
    switch (this) {
      case ExerciseCategory.push:
        return 'Push';
      case ExerciseCategory.pull:
        return 'Pull';
      case ExerciseCategory.legs:
        return 'Legs';
      case ExerciseCategory.core:
        return 'Core';
      case ExerciseCategory.other:
        return 'Other';
    }
  }
}

class ExerciseRecord {
  const ExerciseRecord({
    required this.weight,
    required this.reps,
    required this.oneRM,
    required this.date,
  });

  final double weight;
  final int reps;
  final double oneRM;
  final DateTime date;
}
