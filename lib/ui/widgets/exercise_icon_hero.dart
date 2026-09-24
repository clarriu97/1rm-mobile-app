import 'package:flutter/material.dart';

/// The exercise icon flying from its Home card to the Detail title. Off when
/// the system asks for reduced motion.
class ExerciseIconHero extends StatelessWidget {
  const ExerciseIconHero({
    super.key,
    required this.exerciseId,
    required this.child,
  });

  final String exerciseId;
  final Widget child;

  static Object tagFor(String exerciseId) => 'exercise-icon-$exerciseId';

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(tag: tagFor(exerciseId), child: child),
    );
  }
}
