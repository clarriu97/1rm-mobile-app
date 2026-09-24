// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get units => 'Units';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get kilograms => 'Kilograms';

  @override
  String get pounds => 'Pounds';

  @override
  String get saveError => 'Could not save. Check your device storage.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
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
  String get noRecordsYet => 'No records yet';

  @override
  String get manageExercises => 'Manage exercises';

  @override
  String get allExercisesHidden => 'All exercises are hidden.';

  @override
  String get firstLiftTitle => 'LOG YOUR FIRST LIFT';

  @override
  String get firstLiftBody =>
      'Pick an exercise and enter a set you did — any weight, any reps.';

  @override
  String get history => 'History';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get emptyExerciseBody =>
      'Tap \"Add Entry\" to log your first\ntraining data for this exercise.';

  @override
  String get bestOneRm => 'BEST 1RM';

  @override
  String latestSet(String set, String oneRm) {
    return 'Latest: $set · 1RM $oneRm';
  }

  @override
  String get progress => 'Progress';

  @override
  String get rangeThreeMonths => '3M';

  @override
  String get rangeYear => '1Y';

  @override
  String get rangeAll => 'ALL';

  @override
  String get chartNeedsTwoSessions =>
      'Log at least two sessions to see your progress.';

  @override
  String get chartNotEnoughInRange => 'Not enough entries in this range.';

  @override
  String chartSemantics(String first, String last, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return 'Progress chart: 1RM from $first to $last over $_temp0';
  }

  @override
  String get workingWeights => 'Working weights';

  @override
  String get tablePercentage => 'PERCENTAGE';

  @override
  String get tableReps => 'REPS';

  @override
  String get tableWeight => 'WEIGHT';

  @override
  String roundedTo(String weight) {
    return 'Rounded to the nearest $weight.';
  }

  @override
  String get newPr => 'NEW PR';

  @override
  String newPrSemantics(String exercise, String weight) {
    return 'New personal record: $exercise, $weight';
  }

  @override
  String prGain(String weight) {
    return '+$weight over your previous best';
  }

  @override
  String get enterYourLift => 'ENTER YOUR LIFT';

  @override
  String get editEntry => 'EDIT ENTRY';

  @override
  String get weight => 'Weight';

  @override
  String get repsLabel => 'Reps';

  @override
  String get required => 'Required';

  @override
  String get invalid => 'Invalid';

  @override
  String maxWeight(String weight) {
    return 'Max $weight';
  }

  @override
  String maxReps(int count) {
    return 'Max $count reps';
  }

  @override
  String get estimatedOneRm => 'ESTIMATED 1RM';

  @override
  String highRepsWarning(int count) {
    return 'Estimates are less accurate above $count reps.';
  }

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String historyTitle(String exercise) {
    return '$exercise History';
  }

  @override
  String deletedSet(String set) {
    return 'Deleted $set';
  }

  @override
  String get undo => 'Undo';

  @override
  String get prBadge => 'PR';

  @override
  String get personalRecord => 'Personal record';

  @override
  String get onboardingWhatTitle => 'What is 1RM?';

  @override
  String get onboardingWhatBody =>
      'Your One-Rep Max: the heaviest weight you can lift once. The baseline for all your training.';

  @override
  String get onboardingLogTitle => 'Log your lifts';

  @override
  String get onboardingLogBody =>
      'Enter any set — weight × reps. The Epley formula estimates your max, no need to test it.';

  @override
  String get onboardingTrainTitle => 'Train smarter';

  @override
  String get onboardingTrainBody =>
      'Get working weights for every percentage and rep range. Which unit do you lift in?';

  @override
  String get pickLiftsTitle => 'Pick your lifts';

  @override
  String get pickLiftsBody =>
      'Choose what shows on Home. You can change it any time from Manage exercises.';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get next => 'Next';

  @override
  String get pickAtLeastOneLift => 'Pick at least one lift';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get exercises => 'Exercises';

  @override
  String get searchExercises => 'Search exercises';

  @override
  String get clearSearch => 'Clear search';

  @override
  String shownOnHome(int shown, int total) {
    return '$shown of $total shown on Home';
  }

  @override
  String noExercisesMatch(String query) {
    return 'No exercises match \"$query\".';
  }

  @override
  String get hiddenKeepRecords => 'Hidden exercises keep all their records.';

  @override
  String get newExercise => 'New exercise';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'Zercher Squat';

  @override
  String get enterAName => 'Enter a name';

  @override
  String maxCharacters(int count) {
    return 'Max $count characters';
  }

  @override
  String get exerciseExists => 'That exercise already exists';

  @override
  String get create => 'Create';

  @override
  String get editExercise => 'Edit exercise';

  @override
  String deletedExercise(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $name and $count entries',
      one: 'Deleted $name and 1 entry',
      zero: 'Deleted $name',
    );
    return '$_temp0';
  }

  @override
  String get categorySquat => 'Squat';

  @override
  String get categoryHinge => 'Deadlift & hinge';

  @override
  String get categoryBench => 'Bench & dips';

  @override
  String get categoryOverhead => 'Overhead';

  @override
  String get categoryPull => 'Pulls & rows';

  @override
  String get categoryClean => 'Clean & jerk';

  @override
  String get categorySnatch => 'Snatch';

  @override
  String get categoryCustom => 'Custom';

  @override
  String get exerciseBackSquat => 'Back Squat';

  @override
  String get exerciseFrontSquat => 'Front Squat';

  @override
  String get exerciseOverheadSquat => 'Overhead Squat';

  @override
  String get exerciseBoxSquat => 'Box Squat';

  @override
  String get exerciseLegPress => 'Leg Press';

  @override
  String get exerciseDeadlift => 'Deadlift';

  @override
  String get exerciseSumoDeadlift => 'Sumo Deadlift';

  @override
  String get exerciseRomanianDeadlift => 'Romanian Deadlift';

  @override
  String get exerciseGoodMorning => 'Good Morning';

  @override
  String get exerciseHipThrust => 'Hip Thrust';

  @override
  String get exerciseBenchPress => 'Bench Press';

  @override
  String get exerciseInclineBenchPress => 'Incline Bench Press';

  @override
  String get exerciseCloseGripBenchPress => 'Close-Grip Bench Press';

  @override
  String get exerciseWeightedDip => 'Weighted Dip';

  @override
  String get exerciseOverheadPress => 'Overhead Press';

  @override
  String get exercisePushPress => 'Push Press';

  @override
  String get exercisePushJerk => 'Push Jerk';

  @override
  String get exerciseSplitJerk => 'Split Jerk';

  @override
  String get exerciseBarbellRow => 'Barbell Row';

  @override
  String get exercisePendlayRow => 'Pendlay Row';

  @override
  String get exerciseWeightedPullUp => 'Weighted Pull-Up';

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

  @override
  String exerciseCardSemantics(String exercise, String weight, String when) {
    return '$exercise, best 1RM $weight, $when';
  }

  @override
  String exerciseCardEmptySemantics(String exercise) {
    return '$exercise, no records yet';
  }

  @override
  String get rangeThreeMonthsSemantics => 'Last 3 months';

  @override
  String get rangeYearSemantics => 'Last year';

  @override
  String get rangeAllSemantics => 'All time';

  @override
  String get tablePercentSemantics => 'By percentage';

  @override
  String get tableRepsSemantics => 'By reps';

  @override
  String get editHint => 'Edit';

  @override
  String dateSemantics(String when, String date) {
    return 'Date: $when, $date';
  }

  @override
  String get changeDateHint => 'Change date';

  @override
  String get estimateEmptySemantics => 'Enter weight and reps';
}
