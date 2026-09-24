import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/data/default_exercises.dart';
import 'package:one_rm_mobile/l10n/app_localizations_en.dart';
import 'package:one_rm_mobile/l10n/app_localizations_es.dart';
import 'package:one_rm_mobile/l10n/localized_names.dart';
import 'package:one_rm_mobile/models/exercise.dart';

/// Agreed on 2026-09-23 (#16): gym classics in Spanish; Olympic and CrossFit
/// lifts keep the English names boxes use.
const _spanish = {
  'back_squat': 'Sentadilla trasera',
  'front_squat': 'Sentadilla frontal',
  'overhead_squat': 'Overhead Squat',
  'box_squat': 'Sentadilla al cajón',
  'leg_press': 'Prensa de piernas',
  'deadlift': 'Peso muerto',
  'sumo_deadlift': 'Peso muerto sumo',
  'romanian_deadlift': 'Peso muerto rumano',
  'good_morning': 'Good Morning',
  'hip_thrust': 'Hip Thrust',
  'bench_press': 'Press de banca',
  'incline_bench_press': 'Press de banca inclinado',
  'close_grip_bench_press': 'Press de banca agarre cerrado',
  'weighted_dip': 'Fondos lastrados',
  'overhead_press': 'Press militar',
  'push_press': 'Push Press',
  'push_jerk': 'Push Jerk',
  'split_jerk': 'Split Jerk',
  'barbell_row': 'Remo con barra',
  'pendlay_row': 'Remo Pendlay',
  'weighted_pull_up': 'Dominadas lastradas',
  'power_clean': 'Power Clean',
  'squat_clean': 'Squat Clean',
  'hang_power_clean': 'Hang Power Clean',
  'hang_squat_clean': 'Hang Squat Clean',
  'clean_and_jerk': 'Clean & Jerk',
  'thruster': 'Thruster',
  'cluster': 'Cluster',
  'sumo_deadlift_high_pull': 'Sumo Deadlift High Pull',
  'snatch': 'Snatch',
  'power_snatch': 'Power Snatch',
  'hang_power_snatch': 'Hang Power Snatch',
  'hang_squat_snatch': 'Hang Squat Snatch',
  'snatch_balance': 'Snatch Balance',
};

void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  group('exercise names', () {
    test('every built-in exercise has a translation in each language', () {
      for (final exercise in defaultExercises) {
        expect(en.builtInExerciseName(exercise.id), isNotNull);
        expect(es.builtInExerciseName(exercise.id), isNotNull);
      }
    });

    test('English names are the ones in the library data', () {
      for (final exercise in defaultExercises) {
        expect(en.exerciseName(exercise), exercise.name, reason: exercise.id);
      }
    });

    test('Spanish names are the agreed ones', () {
      expect({
        for (final e in defaultExercises) e.id: es.exerciseName(e),
      }, _spanish);
    });

    test('names are unique within each language', () {
      for (final l10n in [en, es]) {
        final names = defaultExercises.map(l10n.exerciseName).toList();
        expect(names.toSet(), hasLength(names.length));
      }
    });

    test('custom exercises keep the name the user typed', () {
      const custom = ExerciseTemplate(
        id: 'custom_1',
        name: 'Zercher Squat',
        category: ExerciseCategory.custom,
        assetPath: customExerciseIcon,
      );
      expect(en.builtInExerciseName(custom.id), isNull);
      expect(es.exerciseName(custom), 'Zercher Squat');
    });
  });

  group('category names', () {
    test('every category is named in each language', () {
      for (final category in ExerciseCategory.values) {
        expect(en.categoryName(category), isNotEmpty);
        expect(es.categoryName(category), isNotEmpty);
      }
    });

    test('in Spanish', () {
      expect(es.categoryName(ExerciseCategory.squat), 'Sentadilla');
      expect(es.categoryName(ExerciseCategory.hinge), 'Peso muerto y bisagra');
      expect(es.categoryName(ExerciseCategory.bench), 'Banca y fondos');
      expect(es.categoryName(ExerciseCategory.overhead), 'Press sobre cabeza');
      expect(es.categoryName(ExerciseCategory.pull), 'Dominadas y remos');
      expect(es.categoryName(ExerciseCategory.clean), 'Clean & jerk');
      expect(es.categoryName(ExerciseCategory.snatch), 'Snatch');
      expect(es.categoryName(ExerciseCategory.custom), 'Personalizados');
    });
  });
}
