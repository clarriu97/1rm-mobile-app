import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';

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

    test('kg maxWeight is 1000', () {
      expect(WeightUnit.kg.maxWeight, 1000.0);
    });

    test('lbs maxWeight is 2204.62', () {
      expect(WeightUnit.lbs.maxWeight, 2204.62);
    });

    test('lbs maxWeight equals kgToLbs of kg maxWeight', () {
      expect(
        WeightUnit.lbs.maxWeight,
        closeTo(kgToLbs(WeightUnit.kg.maxWeight), 0.01),
      );
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
}
