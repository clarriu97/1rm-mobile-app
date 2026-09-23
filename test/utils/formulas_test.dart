import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

void main() {
  group('generatePercentageTable', () {
    test('uses best 1RM for table generation', () {
      final table = generatePercentageTable(200);
      expect(table.first.percentage, 100);
      expect(table.first.weight, roundToNearest(200));
    });
  });
  group('maxReps', () {
    test('is 50', () {
      expect(maxReps, 50);
    });
  });
  group('parseWeight', () {
    test('parses integer string', () {
      expect(parseWeight('100'), 100.0);
    });

    test('parses dot decimal', () {
      expect(parseWeight('112.5'), 112.5);
    });

    test('parses comma decimal', () {
      expect(parseWeight('112,5'), 112.5);
    });

    test('parses zero', () => expect(parseWeight('0'), 0.0));
  });
  group('tryParseWeight', () {
    test('parses dot decimal', () {
      expect(tryParseWeight('112.5'), 112.5);
    });

    test('parses comma decimal', () {
      expect(tryParseWeight('112,5'), 112.5);
    });

    test('parses integer', () => expect(tryParseWeight('225'), 225.0));

    test('returns null for empty string', () {
      expect(tryParseWeight(''), isNull);
    });

    test('returns null for invalid input', () {
      expect(tryParseWeight('abc'), isNull);
    });

    test('parses negative values as valid doubles', () {
      expect(tryParseWeight('-10'), -10.0);
    });
  });
  group('calculateOneRM', () {
    test('returns the same weight for 1 rep', () {
      expect(calculateOneRM(100, 1), 100.0);
    });

    test('calculates Epley formula correctly for 10 reps', () {
      // Epley: 100 * (1 + 10/30) = 100 * 1.333... = 133.33
      expect(calculateOneRM(100, 10), closeTo(133.33, 0.01));
    });

    test('calculates Epley formula correctly for 5 reps', () {
      // Epley: 100 * (1 + 5/30) = 100 * 1.1666... = 116.67
      expect(calculateOneRM(100, 5), closeTo(116.67, 0.01));
    });

    test('calculates Epley formula correctly for decimal weight', () {
      // Epley: 112.5 * (1 + 8/30) = 112.5 * 1.2666... = 142.5
      expect(calculateOneRM(112.5, 8), closeTo(142.5, 0.01));
    });

    test('handles zero weight', () {
      expect(calculateOneRM(0, 10), 0.0);
    });

    test(
      'handles large values correctly',
      () => expect(calculateOneRM(315, 8), closeTo(399.0, 0.01)),
    );
  });
  group('calculateWeightForPercentage', () {
    test('returns 100% of oneRM', () {
      expect(calculateWeightForPercentage(200, 100), 200.0);
    });

    test('returns 75% of oneRM', () {
      expect(calculateWeightForPercentage(200, 75), 150.0);
    });

    test('returns 50% of oneRM', () {
      expect(calculateWeightForPercentage(200, 50), 100.0);
    });

    test(
      'handles custom percentage',
      () => expect(calculateWeightForPercentage(200, 62.5), 125.0),
    );

    test('returns zero when oneRM is zero', () {
      expect(calculateWeightForPercentage(0, 50), 0.0);
    });
  });
  group('generatePercentageTable', () {
    test('returns correct number of entries', () {
      final table = generatePercentageTable(200);
      expect(table.length, 11);
    });

    test('starts at 100% and ends at 50%', () {
      final table = generatePercentageTable(200);
      expect(table.first.percentage, 100);
      expect(table.last.percentage, 50);
    });

    test('has descending percentages', () {
      final table = generatePercentageTable(200);
      for (var i = 0; i < table.length - 1; i++) {
        expect(table[i].percentage, greaterThan(table[i + 1].percentage));
      }
    });

    test('returns correct weights', () {
      final table = generatePercentageTable(200);
      expect(table.first.weight, 200.0);
      expect(table.last.weight, 100.0);
    });

    test('contains entry for 75%', () {
      final table = generatePercentageTable(200);
      final entry = table.firstWhere((e) => e.percentage == 75);
      expect(entry.weight, 150.0);
    });
  });
  group('roundToNearest', () {
    test('rounds to nearest 1', () {
      expect(roundToNearest(123.0), 123.0);
    });

    test('rounds to nearest 5', () => expect(roundToNearest(138.0, 5), 140.0));

    test('handles exact values', () => expect(roundToNearest(100.0), 100.0));
  });
  group('formatWeight', () {
    test('formats kg with 1 decimal by default', () {
      expect(formatWeight(100.0, WeightUnit.kg), '100.0 kg');
    });

    test('formats lbs with 1 decimal by default', () {
      expect(formatWeight(100.0, WeightUnit.lbs), '220.5 lbs');
    });

    test('formats kg with 0 decimals', () {
      expect(formatWeight(100.0, WeightUnit.kg, 0), '100 kg');
    });

    test('formats lbs with 0 decimals', () {
      expect(formatWeight(100.0, WeightUnit.lbs, 0), '220 lbs');
    });

    test('formats decimal kg correctly', () {
      expect(formatWeight(112.5, WeightUnit.kg), '112.5 kg');
    });

    test('formats decimal kg to lbs correctly', () {
      expect(formatWeight(112.5, WeightUnit.lbs), '248.0 lbs');
    });
  });
  group('generatePercentageTable with unit', () {
    test('uses kg rounding increment by default', () {
      final table = generatePercentageTable(100);
      expect(table.first.weight, 100);
      expect(table.last.weight, 50);
    });

    test('uses lbs rounding increment (5.0)', () {
      final table = generatePercentageTable(220.462, WeightUnit.lbs);
      expect(table.first.weight, 220.0);
      expect(table.last.weight, 110.0);
    });

    test('lbs table rounds to nearest 5', () {
      final table = generatePercentageTable(225, WeightUnit.lbs);
      final entry75 = table.firstWhere((e) => e.percentage == 75);
      expect(entry75.weight % 5, 0.0);
    });

    test('kg table rounds to nearest 1', () {
      final table = generatePercentageTable(100);
      final entry75 = table.firstWhere((e) => e.percentage == 75);
      expect(entry75.weight, 75.0);
    });
  });

  group('estimateOneRMFromInput', () {
    test('valid kg input returns the Epley estimate in kg', () {
      expect(
        estimateOneRMFromInput('100', '5', WeightUnit.kg),
        closeTo(116.67, 0.01),
      );
    });

    test('1 rep returns the weight itself', () {
      expect(estimateOneRMFromInput('140', '1', WeightUnit.kg), 140);
    });

    test('lbs input is converted to kg', () {
      expect(
        estimateOneRMFromInput('225', '1', WeightUnit.lbs),
        closeTo(102.06, 0.01),
      );
    });

    test('accepts comma decimals and surrounding spaces', () {
      expect(estimateOneRMFromInput(' 112,5 ', ' 1 ', WeightUnit.kg), 112.5);
    });

    test('returns null for empty or unparsable fields', () {
      expect(estimateOneRMFromInput('', '5', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('100', '', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('abc', '5', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('100', '5.5', WeightUnit.kg), isNull);
    });

    test('returns null for zero or negative values', () {
      expect(estimateOneRMFromInput('0', '5', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('-10', '5', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('100', '0', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('100', '-1', WeightUnit.kg), isNull);
    });

    test('respects the per-unit weight limit', () {
      expect(estimateOneRMFromInput('1000', '1', WeightUnit.kg), 1000);
      expect(estimateOneRMFromInput('1000.1', '1', WeightUnit.kg), isNull);
      expect(estimateOneRMFromInput('2204.62', '1', WeightUnit.lbs), isNotNull);
      expect(estimateOneRMFromInput('2205', '1', WeightUnit.lbs), isNull);
    });

    test('respects the reps limit', () {
      expect(
        estimateOneRMFromInput('100', '$maxReps', WeightUnit.kg),
        isNotNull,
      );
      expect(
        estimateOneRMFromInput('100', '${maxReps + 1}', WeightUnit.kg),
        isNull,
      );
    });
  });

  group('weightForReps', () {
    test('1 rep (or less) is the 1RM itself', () {
      expect(weightForReps(150, 1), 150);
      expect(weightForReps(150, 0), 150);
    });

    test('inverts Epley exactly', () {
      for (final reps in [2, 5, 8, 10]) {
        final w = weightForReps(150, reps);
        expect(calculateOneRM(w, reps), closeTo(150, 1e-9));
      }
    });

    test('10 reps is 75 % of the 1RM', () {
      expect(weightForReps(200, 10), closeTo(150, 1e-9));
    });
  });

  group('generateRepsTable', () {
    test('covers 1 to 10 reps with decreasing weights', () {
      final table = generateRepsTable(150);
      expect(table.map((e) => e.reps), List.generate(10, (i) => i + 1));
      for (var i = 1; i < table.length; i++) {
        expect(table[i].weight, lessThanOrEqualTo(table[i - 1].weight));
      }
      expect(table.first.weight, 150);
    });

    test('rounds to 1 kg and 5 lbs', () {
      for (final e in generateRepsTable(152.3)) {
        expect(e.weight % 1, 0);
      }
      for (final e in generateRepsTable(331, WeightUnit.lbs)) {
        expect(e.weight % 5, 0);
      }
    });

    test('custom length', () {
      expect(generateRepsTable(100, WeightUnit.kg, 5), hasLength(5));
    });
  });

  group('formatUnitValue', () {
    test('formats without converting, 0 decimals by default', () {
      expect(formatUnitValue(220, WeightUnit.lbs), '220 lbs');
      expect(formatUnitValue(117, WeightUnit.kg), '117 kg');
      expect(formatUnitValue(117.25, WeightUnit.kg, 1), '117.3 kg');
    });
  });
}
