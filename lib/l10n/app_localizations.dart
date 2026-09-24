import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @kilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get kilograms;

  /// No description provided for @pounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get pounds;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your device storage.'**
  String get saveError;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String weeksAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String monthsAgo(int count);

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String yearsAgo(int count);

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rep} other{{count} reps}}'**
  String reps(int count);

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'{weight} × {reps, plural, =1{1 rep} other{{reps} reps}}'**
  String set(String weight, int reps);

  /// No description provided for @oneRmValue.
  ///
  /// In en, this message translates to:
  /// **'1RM: {weight}'**
  String oneRmValue(String weight);

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// No description provided for @manageExercises.
  ///
  /// In en, this message translates to:
  /// **'Manage exercises'**
  String get manageExercises;

  /// No description provided for @allExercisesHidden.
  ///
  /// In en, this message translates to:
  /// **'All exercises are hidden.'**
  String get allExercisesHidden;

  /// No description provided for @firstLiftTitle.
  ///
  /// In en, this message translates to:
  /// **'LOG YOUR FIRST LIFT'**
  String get firstLiftTitle;

  /// No description provided for @firstLiftBody.
  ///
  /// In en, this message translates to:
  /// **'Pick an exercise and enter a set you did — any weight, any reps.'**
  String get firstLiftBody;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @emptyExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Entry\" to log your first\ntraining data for this exercise.'**
  String get emptyExerciseBody;

  /// No description provided for @bestOneRm.
  ///
  /// In en, this message translates to:
  /// **'BEST 1RM'**
  String get bestOneRm;

  /// No description provided for @latestSet.
  ///
  /// In en, this message translates to:
  /// **'Latest: {set} · 1RM {oneRm}'**
  String latestSet(String set, String oneRm);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get rangeThreeMonths;

  /// No description provided for @rangeYear.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get rangeYear;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get rangeAll;

  /// No description provided for @chartNeedsTwoSessions.
  ///
  /// In en, this message translates to:
  /// **'Log at least two sessions to see your progress.'**
  String get chartNeedsTwoSessions;

  /// No description provided for @chartNotEnoughInRange.
  ///
  /// In en, this message translates to:
  /// **'Not enough entries in this range.'**
  String get chartNotEnoughInRange;

  /// No description provided for @chartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Progress chart: 1RM from {first} to {last} over {count, plural, =1{1 entry} other{{count} entries}}'**
  String chartSemantics(String first, String last, int count);

  /// No description provided for @workingWeights.
  ///
  /// In en, this message translates to:
  /// **'Working weights'**
  String get workingWeights;

  /// No description provided for @tablePercentage.
  ///
  /// In en, this message translates to:
  /// **'PERCENTAGE'**
  String get tablePercentage;

  /// No description provided for @tableReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get tableReps;

  /// No description provided for @tableWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get tableWeight;

  /// No description provided for @roundedTo.
  ///
  /// In en, this message translates to:
  /// **'Rounded to the nearest {weight}.'**
  String roundedTo(String weight);

  /// No description provided for @newPr.
  ///
  /// In en, this message translates to:
  /// **'NEW PR'**
  String get newPr;

  /// No description provided for @newPrSemantics.
  ///
  /// In en, this message translates to:
  /// **'New personal record: {exercise}, {weight}'**
  String newPrSemantics(String exercise, String weight);

  /// No description provided for @prGain.
  ///
  /// In en, this message translates to:
  /// **'+{weight} over your previous best'**
  String prGain(String weight);

  /// No description provided for @enterYourLift.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR LIFT'**
  String get enterYourLift;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'EDIT ENTRY'**
  String get editEntry;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @maxWeight.
  ///
  /// In en, this message translates to:
  /// **'Max {weight}'**
  String maxWeight(String weight);

  /// No description provided for @maxReps.
  ///
  /// In en, this message translates to:
  /// **'Max {count} reps'**
  String maxReps(int count);

  /// No description provided for @estimatedOneRm.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED 1RM'**
  String get estimatedOneRm;

  /// No description provided for @highRepsWarning.
  ///
  /// In en, this message translates to:
  /// **'Estimates are less accurate above {count} reps.'**
  String highRepsWarning(int count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'{exercise} History'**
  String historyTitle(String exercise);

  /// No description provided for @deletedSet.
  ///
  /// In en, this message translates to:
  /// **'Deleted {set}'**
  String deletedSet(String set);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @prBadge.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get prBadge;

  /// No description provided for @personalRecord.
  ///
  /// In en, this message translates to:
  /// **'Personal record'**
  String get personalRecord;

  /// No description provided for @onboardingWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is 1RM?'**
  String get onboardingWhatTitle;

  /// No description provided for @onboardingWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Your One-Rep Max: the heaviest weight you can lift once. The baseline for all your training.'**
  String get onboardingWhatBody;

  /// No description provided for @onboardingLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log your lifts'**
  String get onboardingLogTitle;

  /// No description provided for @onboardingLogBody.
  ///
  /// In en, this message translates to:
  /// **'Enter any set — weight × reps. The Epley formula estimates your max, no need to test it.'**
  String get onboardingLogBody;

  /// No description provided for @onboardingTrainTitle.
  ///
  /// In en, this message translates to:
  /// **'Train smarter'**
  String get onboardingTrainTitle;

  /// No description provided for @onboardingTrainBody.
  ///
  /// In en, this message translates to:
  /// **'Get working weights for every percentage and rep range. Which unit do you lift in?'**
  String get onboardingTrainBody;

  /// No description provided for @pickLiftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your lifts'**
  String get pickLiftsTitle;

  /// No description provided for @pickLiftsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose what shows on Home. You can change it any time from Manage exercises.'**
  String get pickLiftsBody;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pickAtLeastOneLift.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one lift'**
  String get pickAtLeastOneLift;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get searchExercises;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @shownOnHome.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} shown on Home'**
  String shownOnHome(int shown, int total);

  /// No description provided for @noExercisesMatch.
  ///
  /// In en, this message translates to:
  /// **'No exercises match \"{query}\".'**
  String noExercisesMatch(String query);

  /// No description provided for @hiddenKeepRecords.
  ///
  /// In en, this message translates to:
  /// **'Hidden exercises keep all their records.'**
  String get hiddenKeepRecords;

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get newExercise;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Zercher Squat'**
  String get nameHint;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterAName;

  /// No description provided for @maxCharacters.
  ///
  /// In en, this message translates to:
  /// **'Max {count} characters'**
  String maxCharacters(int count);

  /// No description provided for @exerciseExists.
  ///
  /// In en, this message translates to:
  /// **'That exercise already exists'**
  String get exerciseExists;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get editExercise;

  /// No description provided for @deletedExercise.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Deleted {name}} =1{Deleted {name} and 1 entry} other{Deleted {name} and {count} entries}}'**
  String deletedExercise(String name, int count);

  /// No description provided for @categorySquat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get categorySquat;

  /// No description provided for @categoryHinge.
  ///
  /// In en, this message translates to:
  /// **'Deadlift & hinge'**
  String get categoryHinge;

  /// No description provided for @categoryBench.
  ///
  /// In en, this message translates to:
  /// **'Bench & dips'**
  String get categoryBench;

  /// No description provided for @categoryOverhead.
  ///
  /// In en, this message translates to:
  /// **'Overhead'**
  String get categoryOverhead;

  /// No description provided for @categoryPull.
  ///
  /// In en, this message translates to:
  /// **'Pulls & rows'**
  String get categoryPull;

  /// No description provided for @categoryClean.
  ///
  /// In en, this message translates to:
  /// **'Clean & jerk'**
  String get categoryClean;

  /// No description provided for @categorySnatch.
  ///
  /// In en, this message translates to:
  /// **'Snatch'**
  String get categorySnatch;

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @exerciseBackSquat.
  ///
  /// In en, this message translates to:
  /// **'Back Squat'**
  String get exerciseBackSquat;

  /// No description provided for @exerciseFrontSquat.
  ///
  /// In en, this message translates to:
  /// **'Front Squat'**
  String get exerciseFrontSquat;

  /// No description provided for @exerciseOverheadSquat.
  ///
  /// In en, this message translates to:
  /// **'Overhead Squat'**
  String get exerciseOverheadSquat;

  /// No description provided for @exerciseBoxSquat.
  ///
  /// In en, this message translates to:
  /// **'Box Squat'**
  String get exerciseBoxSquat;

  /// No description provided for @exerciseLegPress.
  ///
  /// In en, this message translates to:
  /// **'Leg Press'**
  String get exerciseLegPress;

  /// No description provided for @exerciseDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get exerciseDeadlift;

  /// No description provided for @exerciseSumoDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Sumo Deadlift'**
  String get exerciseSumoDeadlift;

  /// No description provided for @exerciseRomanianDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Romanian Deadlift'**
  String get exerciseRomanianDeadlift;

  /// No description provided for @exerciseGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get exerciseGoodMorning;

  /// No description provided for @exerciseHipThrust.
  ///
  /// In en, this message translates to:
  /// **'Hip Thrust'**
  String get exerciseHipThrust;

  /// No description provided for @exerciseBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get exerciseBenchPress;

  /// No description provided for @exerciseInclineBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Incline Bench Press'**
  String get exerciseInclineBenchPress;

  /// No description provided for @exerciseCloseGripBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Close-Grip Bench Press'**
  String get exerciseCloseGripBenchPress;

  /// No description provided for @exerciseWeightedDip.
  ///
  /// In en, this message translates to:
  /// **'Weighted Dip'**
  String get exerciseWeightedDip;

  /// No description provided for @exerciseOverheadPress.
  ///
  /// In en, this message translates to:
  /// **'Overhead Press'**
  String get exerciseOverheadPress;

  /// No description provided for @exercisePushPress.
  ///
  /// In en, this message translates to:
  /// **'Push Press'**
  String get exercisePushPress;

  /// No description provided for @exercisePushJerk.
  ///
  /// In en, this message translates to:
  /// **'Push Jerk'**
  String get exercisePushJerk;

  /// No description provided for @exerciseSplitJerk.
  ///
  /// In en, this message translates to:
  /// **'Split Jerk'**
  String get exerciseSplitJerk;

  /// No description provided for @exerciseBarbellRow.
  ///
  /// In en, this message translates to:
  /// **'Barbell Row'**
  String get exerciseBarbellRow;

  /// No description provided for @exercisePendlayRow.
  ///
  /// In en, this message translates to:
  /// **'Pendlay Row'**
  String get exercisePendlayRow;

  /// No description provided for @exerciseWeightedPullUp.
  ///
  /// In en, this message translates to:
  /// **'Weighted Pull-Up'**
  String get exerciseWeightedPullUp;

  /// No description provided for @exercisePowerClean.
  ///
  /// In en, this message translates to:
  /// **'Power Clean'**
  String get exercisePowerClean;

  /// No description provided for @exerciseSquatClean.
  ///
  /// In en, this message translates to:
  /// **'Squat Clean'**
  String get exerciseSquatClean;

  /// No description provided for @exerciseHangPowerClean.
  ///
  /// In en, this message translates to:
  /// **'Hang Power Clean'**
  String get exerciseHangPowerClean;

  /// No description provided for @exerciseHangSquatClean.
  ///
  /// In en, this message translates to:
  /// **'Hang Squat Clean'**
  String get exerciseHangSquatClean;

  /// No description provided for @exerciseCleanAndJerk.
  ///
  /// In en, this message translates to:
  /// **'Clean & Jerk'**
  String get exerciseCleanAndJerk;

  /// No description provided for @exerciseThruster.
  ///
  /// In en, this message translates to:
  /// **'Thruster'**
  String get exerciseThruster;

  /// No description provided for @exerciseCluster.
  ///
  /// In en, this message translates to:
  /// **'Cluster'**
  String get exerciseCluster;

  /// No description provided for @exerciseSumoDeadliftHighPull.
  ///
  /// In en, this message translates to:
  /// **'Sumo Deadlift High Pull'**
  String get exerciseSumoDeadliftHighPull;

  /// No description provided for @exerciseSnatch.
  ///
  /// In en, this message translates to:
  /// **'Snatch'**
  String get exerciseSnatch;

  /// No description provided for @exercisePowerSnatch.
  ///
  /// In en, this message translates to:
  /// **'Power Snatch'**
  String get exercisePowerSnatch;

  /// No description provided for @exerciseHangPowerSnatch.
  ///
  /// In en, this message translates to:
  /// **'Hang Power Snatch'**
  String get exerciseHangPowerSnatch;

  /// No description provided for @exerciseHangSquatSnatch.
  ///
  /// In en, this message translates to:
  /// **'Hang Squat Snatch'**
  String get exerciseHangSquatSnatch;

  /// No description provided for @exerciseSnatchBalance.
  ///
  /// In en, this message translates to:
  /// **'Snatch Balance'**
  String get exerciseSnatchBalance;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
