import '../models/weight_unit.dart';

const int maxReps = 50;

class PercentageEntry {
  const PercentageEntry({required this.percentage, required this.weight});

  final int percentage;
  final double weight;
}

double parseWeight(String input) {
  return double.parse(input.replaceAll(',', '.'));
}

double? tryParseWeight(String input) {
  return double.tryParse(input.replaceAll(',', '.'));
}

double calculateOneRM(double weight, int reps) {
  if (reps <= 1) return weight;
  return weight * (1 + reps / 30);
}

double calculateWeightForPercentage(double oneRM, double percentage) {
  return oneRM * percentage / 100;
}

/// Working weights from 100 % down to 50 %. [oneRM] must already be in
/// [unit] so the rounding lands on loadable plates (1 kg / 5 lbs).
List<PercentageEntry> generatePercentageTable(
  double oneRM, [
  WeightUnit unit = WeightUnit.kg,
]) {
  return [
    for (var pct = 100; pct >= 50; pct -= 5)
      PercentageEntry(
        percentage: pct,
        weight: roundToNearest(
          calculateWeightForPercentage(oneRM, pct.toDouble()),
          unit.roundingIncrement,
        ),
      ),
  ];
}

double roundToNearest(double value, [double increment = 1.0]) {
  return (value / increment).round() * increment;
}

String formatWeight(double weightInKg, WeightUnit unit, [int decimals = 1]) {
  final displayValue = unit == WeightUnit.lbs
      ? kgToLbs(weightInKg)
      : weightInKg;
  return '${displayValue.toStringAsFixed(decimals)} ${unit.displayName}';
}

/// Above this many reps the Epley estimate gets noticeably less reliable.
const int accurateRepsLimit = 10;

/// Estimated 1RM in kg from raw form input, or null if either field is not
/// a valid value (same rules as the entry form's validators).
double? estimateOneRMFromInput(
  String weightText,
  String repsText,
  WeightUnit unit,
) {
  final weight = tryParseWeight(weightText.trim());
  final reps = int.tryParse(repsText.trim());
  if (weight == null || weight <= 0 || weight > unit.maxWeight) return null;
  if (reps == null || reps <= 0 || reps > maxReps) return null;
  final weightInKg = unit == WeightUnit.lbs ? lbsToKg(weight) : weight;
  return calculateOneRM(weightInKg, reps);
}

class RepMaxEntry {
  const RepMaxEntry({required this.reps, required this.weight});

  final int reps;
  final double weight;
}

/// Inverse Epley: the weight you should manage for [reps] given [oneRM].
double weightForReps(double oneRM, int reps) =>
    reps <= 1 ? oneRM : oneRM / (1 + reps / 30);

/// Estimated rep maxes from 1 to [maxRepsShown]. [oneRM] must be in [unit].
List<RepMaxEntry> generateRepsTable(
  double oneRM, [
  WeightUnit unit = WeightUnit.kg,
  int maxRepsShown = 10,
]) {
  return [
    for (var reps = 1; reps <= maxRepsShown; reps++)
      RepMaxEntry(
        reps: reps,
        weight: roundToNearest(
          weightForReps(oneRM, reps),
          unit.roundingIncrement,
        ),
      ),
  ];
}

/// Formats a value that is already in [unit] (no conversion).
String formatUnitValue(double value, WeightUnit unit, [int decimals = 0]) =>
    '${value.toStringAsFixed(decimals)} ${unit.displayName}';
