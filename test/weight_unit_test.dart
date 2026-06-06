import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/utils/formulas.dart';

void main() {
  group('WeightUnit', () {
    test('kg displayName is "kg"', () {
      expect(WeightUnit.kg.displayName, 'kg');
    });

    test('lbs displayName is "lbs"', () {
      expect(WeightUnit.lbs.displayName, 'lbs');
    });

    test('kg rounding increment is 1.0', () {
      expect(WeightUnit.kg.roundingIncrement, 1.0);
    });

    test('lbs rounding increment is 5.0', () {
      expect(WeightUnit.lbs.roundingIncrement, 5.0);
    });
  });

  group('kgToLbs', () {
    test('converts 100 kg to lbs', () {
      expect(kgToLbs(100), closeTo(220.462, 0.001));
    });

    test('converts 0 kg to 0 lbs', () {
      expect(kgToLbs(0), 0.0);
    });

    test('converts decimal kg to lbs', () {
      expect(kgToLbs(50.5), closeTo(111.333, 0.001));
    });
  });

  group('lbsToKg', () {
    test('converts 225 lbs to kg', () {
      expect(lbsToKg(225), closeTo(102.058, 0.001));
    });

    test('converts 0 lbs to 0 kg', () {
      expect(lbsToKg(0), 0.0);
    });

    test('converts decimal lbs to kg', () {
      expect(lbsToKg(112.5), closeTo(51.029, 0.001));
    });
  });

  group('roundtrip conversion', () {
    test('225 lbs roundtrips through kg', () {
      final kg = lbsToKg(225);
      final lbs = kgToLbs(kg);
      expect(lbs, closeTo(225, 0.0001));
    });

    test('100 kg roundtrips through lbs', () {
      final lbs = kgToLbs(100);
      final kg = lbsToKg(lbs);
      expect(kg, closeTo(100, 0.0001));
    });

    test('315 lbs roundtrips through kg', () {
      final kg = lbsToKg(315);
      final lbs = kgToLbs(kg);
      expect(lbs, closeTo(315, 0.0001));
    });
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
}
