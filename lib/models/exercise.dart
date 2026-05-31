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

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'oneRM': oneRM,
    'date': date.toIso8601String(),
  };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
    weight: (json['weight'] as num).toDouble(),
    reps: (json['reps'] as num).toInt(),
    oneRM: (json['oneRM'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );

  static ExerciseRecord? tryFromJson(Map<String, dynamic> json) {
    try {
      return ExerciseRecord.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
