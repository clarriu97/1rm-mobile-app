// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Ajustes';

  @override
  String get units => 'Unidades';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Como el dispositivo';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get kilograms => 'Kilogramos';

  @override
  String get pounds => 'Libras';

  @override
  String get saveError =>
      'No se pudo guardar. Revisa el almacenamiento del dispositivo.';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count semanas',
      one: 'Hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count meses',
      one: 'Hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String reps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
      one: '1 rep',
    );
    return '$_temp0';
  }

  @override
  String set(String weight, int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: '$reps reps',
      one: '1 rep',
    );
    return '$weight × $_temp0';
  }

  @override
  String oneRmValue(String weight) {
    return '1RM: $weight';
  }

  @override
  String get noRecordsYet => 'Aún no hay registros';

  @override
  String get manageExercises => 'Gestionar ejercicios';

  @override
  String get allExercisesHidden => 'Todos los ejercicios están ocultos.';

  @override
  String get firstLiftTitle => 'APUNTA TU PRIMERA SERIE';

  @override
  String get firstLiftBody =>
      'Elige un ejercicio e introduce una serie que hayas hecho: cualquier peso, cualquier número de reps.';

  @override
  String get history => 'Historial';

  @override
  String get addEntry => 'Añadir registro';

  @override
  String get emptyExerciseBody =>
      'Toca «Añadir registro» para apuntar\ntu primera serie de este ejercicio.';

  @override
  String get bestOneRm => 'MEJOR 1RM';

  @override
  String latestSet(String set, String oneRm) {
    return 'Última: $set · 1RM $oneRm';
  }

  @override
  String get progress => 'Progreso';

  @override
  String get rangeThreeMonths => '3M';

  @override
  String get rangeYear => '1A';

  @override
  String get rangeAll => 'TODO';

  @override
  String get chartNeedsTwoSessions =>
      'Apunta al menos dos sesiones para ver tu progreso.';

  @override
  String get chartNotEnoughInRange =>
      'No hay suficientes registros en este periodo.';

  @override
  String chartSemantics(String first, String last, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return 'Gráfico de progreso: 1RM de $first a $last en $_temp0';
  }

  @override
  String get workingWeights => 'Pesos de trabajo';

  @override
  String get tablePercentage => 'PORCENTAJE';

  @override
  String get tableReps => 'REPS';

  @override
  String get tableWeight => 'PESO';

  @override
  String roundedTo(String weight) {
    return 'Redondeado a múltiplos de $weight.';
  }

  @override
  String get newPr => 'NUEVO PR';

  @override
  String newPrSemantics(String exercise, String weight) {
    return 'Nueva marca personal: $exercise, $weight';
  }

  @override
  String prGain(String weight) {
    return '+$weight sobre tu mejor marca anterior';
  }

  @override
  String get enterYourLift => 'INTRODUCE TU SERIE';

  @override
  String get editEntry => 'EDITAR REGISTRO';

  @override
  String get weight => 'Peso';

  @override
  String get repsLabel => 'Reps';

  @override
  String get required => 'Obligatorio';

  @override
  String get invalid => 'No válido';

  @override
  String maxWeight(String weight) {
    return 'Máx. $weight';
  }

  @override
  String maxReps(int count) {
    return 'Máx. $count reps';
  }

  @override
  String get estimatedOneRm => '1RM ESTIMADO';

  @override
  String highRepsWarning(int count) {
    return 'Las estimaciones son menos precisas por encima de $count reps.';
  }

  @override
  String get save => 'Guardar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String historyTitle(String exercise) {
    return 'Historial de $exercise';
  }

  @override
  String deletedSet(String set) {
    return 'Borrado: $set';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get prBadge => 'PR';

  @override
  String get personalRecord => 'Marca personal';

  @override
  String get onboardingWhatTitle => '¿Qué es el 1RM?';

  @override
  String get onboardingWhatBody =>
      'Tu repetición máxima: el mayor peso que puedes levantar una vez. La base de todo tu entrenamiento.';

  @override
  String get onboardingLogTitle => 'Apunta tus series';

  @override
  String get onboardingLogBody =>
      'Introduce cualquier serie: peso × reps. La fórmula de Epley estima tu máximo, sin necesidad de probarlo.';

  @override
  String get onboardingTrainTitle => 'Entrena con cabeza';

  @override
  String get onboardingTrainBody =>
      'Pesos de trabajo para cada porcentaje y rango de repeticiones. ¿En qué unidad levantas?';

  @override
  String get pickLiftsTitle => 'Elige tus ejercicios';

  @override
  String get pickLiftsBody =>
      'Elige qué aparece en Inicio. Puedes cambiarlo cuando quieras desde Gestionar ejercicios.';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get next => 'Siguiente';

  @override
  String get pickAtLeastOneLift => 'Elige al menos un ejercicio';

  @override
  String get getStarted => 'Empezar';

  @override
  String get skip => 'Saltar';

  @override
  String get exercises => 'Ejercicios';

  @override
  String get searchExercises => 'Buscar ejercicios';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String shownOnHome(int shown, int total) {
    return '$shown de $total en Inicio';
  }

  @override
  String noExercisesMatch(String query) {
    return 'Ningún ejercicio coincide con «$query».';
  }

  @override
  String get hiddenKeepRecords =>
      'Los ejercicios ocultos conservan todos sus registros.';

  @override
  String get newExercise => 'Nuevo ejercicio';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameHint => 'Sentadilla Zercher';

  @override
  String get enterAName => 'Escribe un nombre';

  @override
  String maxCharacters(int count) {
    return 'Máximo $count caracteres';
  }

  @override
  String get exerciseExists => 'Ese ejercicio ya existe';

  @override
  String get create => 'Crear';

  @override
  String get editExercise => 'Editar ejercicio';

  @override
  String deletedExercise(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Borrado: $name y $count registros',
      one: 'Borrado: $name y 1 registro',
      zero: 'Borrado: $name',
    );
    return '$_temp0';
  }

  @override
  String get categorySquat => 'Sentadilla';

  @override
  String get categoryHinge => 'Peso muerto y bisagra';

  @override
  String get categoryBench => 'Banca y fondos';

  @override
  String get categoryOverhead => 'Press sobre cabeza';

  @override
  String get categoryPull => 'Dominadas y remos';

  @override
  String get categoryClean => 'Clean & jerk';

  @override
  String get categorySnatch => 'Snatch';

  @override
  String get categoryCustom => 'Personalizados';

  @override
  String get exerciseBackSquat => 'Sentadilla trasera';

  @override
  String get exerciseFrontSquat => 'Sentadilla frontal';

  @override
  String get exerciseOverheadSquat => 'Overhead Squat';

  @override
  String get exerciseBoxSquat => 'Sentadilla al cajón';

  @override
  String get exerciseLegPress => 'Prensa de piernas';

  @override
  String get exerciseDeadlift => 'Peso muerto';

  @override
  String get exerciseSumoDeadlift => 'Peso muerto sumo';

  @override
  String get exerciseRomanianDeadlift => 'Peso muerto rumano';

  @override
  String get exerciseGoodMorning => 'Good Morning';

  @override
  String get exerciseHipThrust => 'Hip Thrust';

  @override
  String get exerciseBenchPress => 'Press de banca';

  @override
  String get exerciseInclineBenchPress => 'Press de banca inclinado';

  @override
  String get exerciseCloseGripBenchPress => 'Press de banca agarre cerrado';

  @override
  String get exerciseWeightedDip => 'Fondos lastrados';

  @override
  String get exerciseOverheadPress => 'Press militar';

  @override
  String get exercisePushPress => 'Push Press';

  @override
  String get exercisePushJerk => 'Push Jerk';

  @override
  String get exerciseSplitJerk => 'Split Jerk';

  @override
  String get exerciseBarbellRow => 'Remo con barra';

  @override
  String get exercisePendlayRow => 'Remo Pendlay';

  @override
  String get exerciseWeightedPullUp => 'Dominadas lastradas';

  @override
  String get exercisePowerClean => 'Power Clean';

  @override
  String get exerciseSquatClean => 'Squat Clean';

  @override
  String get exerciseHangPowerClean => 'Hang Power Clean';

  @override
  String get exerciseHangSquatClean => 'Hang Squat Clean';

  @override
  String get exerciseCleanAndJerk => 'Clean & Jerk';

  @override
  String get exerciseThruster => 'Thruster';

  @override
  String get exerciseCluster => 'Cluster';

  @override
  String get exerciseSumoDeadliftHighPull => 'Sumo Deadlift High Pull';

  @override
  String get exerciseSnatch => 'Snatch';

  @override
  String get exercisePowerSnatch => 'Power Snatch';

  @override
  String get exerciseHangPowerSnatch => 'Hang Power Snatch';

  @override
  String get exerciseHangSquatSnatch => 'Hang Squat Snatch';

  @override
  String get exerciseSnatchBalance => 'Snatch Balance';
}
