import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

void main() {
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
}
