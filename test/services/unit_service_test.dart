import 'package:flutter_test/flutter_test.dart';
import 'package:one_rm_mobile/models/weight_unit.dart';
import 'package:one_rm_mobile/services/unit_service.dart';

void main() {
  group('UnitService.forTesting', () {
    test('defaults to kg', () async {
      final service = UnitService.forTesting();
      expect(await service.getUnit(), WeightUnit.kg);
    });

    test('can be initialized with lbs', () async {
      final service = UnitService.forTesting(unit: WeightUnit.lbs);
      expect(await service.getUnit(), WeightUnit.lbs);
    });

    test('setUnit changes the unit', () async {
      final service = UnitService.forTesting();
      expect(await service.getUnit(), WeightUnit.kg);

      await service.setUnit(WeightUnit.lbs);
      expect(await service.getUnit(), WeightUnit.lbs);
    });

    test('setUnit can change back to kg', () async {
      final service = UnitService.forTesting(unit: WeightUnit.lbs);
      expect(await service.getUnit(), WeightUnit.lbs);

      await service.setUnit(WeightUnit.kg);
      expect(await service.getUnit(), WeightUnit.kg);
    });
  });
}
