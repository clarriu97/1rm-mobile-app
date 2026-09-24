// Single entry point for every end-to-end flow, so the app is built and
// installed once per run instead of once per file:
//   flutter test integration_test/app_test.dart -d <device-id>
// (one flow: add --plain-name '<test name>')
import 'package:flutter_test/flutter_test.dart';

import 'flows/history_flow.dart';
import 'flows/language_flow.dart';
import 'flows/log_and_pr_flow.dart';
import 'flows/manage_exercises_flow.dart';
import 'flows/onboarding_flow.dart';
import 'flows/units_flow.dart';
import 'helpers.dart';

void main() {
  setUpE2E();

  group('onboarding', onboardingFlows);
  group('log and pr', logAndPrFlows);
  group('history', historyFlows);
  group('manage exercises', manageExercisesFlows);
  group('units', unitsFlows);
  group('language', languageFlows);
}
