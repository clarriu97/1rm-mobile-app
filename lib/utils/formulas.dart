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

List<PercentageEntry> generatePercentageTable(double oneRM) {
  return [
    for (var pct = 100; pct >= 50; pct -= 5)
      PercentageEntry(
        percentage: pct,
        weight: roundToNearest(
          calculateWeightForPercentage(oneRM, pct.toDouble()),
        ),
      ),
  ];
}

double roundToNearest(double value, [double increment = 1.0]) {
  return (value / increment).round() * increment;
}
