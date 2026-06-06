import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_unit.dart';

abstract class UnitService {
  Future<WeightUnit> getUnit();
  Future<void> setUnit(WeightUnit unit);

  static Future<UnitService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return _UnitServiceImpl(prefs);
  }

  static UnitService forTesting({WeightUnit unit = WeightUnit.kg}) =>
      _FakeUnitService(unit: unit);
}

class _UnitServiceImpl implements UnitService {
  _UnitServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'weight_unit';

  @override
  Future<WeightUnit> getUnit() async {
    final value = _prefs.getString(_key);
    if (value == null) return WeightUnit.kg;
    return WeightUnit.values.firstWhere(
      (u) => u.name == value,
      orElse: () => WeightUnit.kg,
    );
  }

  @override
  Future<void> setUnit(WeightUnit unit) => _prefs.setString(_key, unit.name);
}

class _FakeUnitService implements UnitService {
  _FakeUnitService({WeightUnit unit = WeightUnit.kg}) : _unit = unit;

  WeightUnit _unit;

  @override
  Future<WeightUnit> getUnit() async => _unit;

  @override
  Future<void> setUnit(WeightUnit unit) async {
    _unit = unit;
  }
}
