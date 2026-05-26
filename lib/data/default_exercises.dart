import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.name,
    required this.category,
    required this.icon,
  });

  final String name;
  final ExerciseCategory category;
  final IconData icon;
}

const List<ExerciseTemplate> defaultExercises = [
  ExerciseTemplate(
    name: 'Back Squat',
    category: ExerciseCategory.legs,
    icon: Icons.fitness_center_rounded,
  ),
  ExerciseTemplate(
    name: 'Front Squat',
    category: ExerciseCategory.legs,
    icon: Icons.sensors_rounded,
  ),
  ExerciseTemplate(
    name: 'Bench Press',
    category: ExerciseCategory.push,
    icon: Icons.horizontal_distribute_rounded,
  ),
  ExerciseTemplate(
    name: 'Deadlift',
    category: ExerciseCategory.pull,
    icon: Icons.arrow_circle_up_rounded,
  ),
  ExerciseTemplate(
    name: 'Overhead Press',
    category: ExerciseCategory.push,
    icon: Icons.keyboard_arrow_up_rounded,
  ),
  ExerciseTemplate(
    name: 'Barbell Row',
    category: ExerciseCategory.pull,
    icon: Icons.replay_rounded,
  ),
  ExerciseTemplate(
    name: 'Pull-Up',
    category: ExerciseCategory.pull,
    icon: Icons.pan_tool_rounded,
  ),
  ExerciseTemplate(
    name: 'Romanian Deadlift',
    category: ExerciseCategory.pull,
    icon: Icons.arrow_circle_down_rounded,
  ),
  ExerciseTemplate(
    name: 'Power Clean',
    category: ExerciseCategory.legs,
    icon: Icons.bolt_rounded,
  ),
  ExerciseTemplate(
    name: 'Snatch',
    category: ExerciseCategory.legs,
    icon: Icons.flash_on_rounded,
  ),
  ExerciseTemplate(
    name: 'Dip',
    category: ExerciseCategory.push,
    icon: Icons.keyboard_double_arrow_down_rounded,
  ),
  ExerciseTemplate(
    name: 'Hip Thrust',
    category: ExerciseCategory.legs,
    icon: Icons.straighten_rounded,
  ),
];
