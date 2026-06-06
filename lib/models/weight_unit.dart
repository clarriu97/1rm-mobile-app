enum WeightUnit {
  kg,
  lbs;

  String get displayName {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
    }
  }

  double get roundingIncrement {
    switch (this) {
      case WeightUnit.kg:
        return 1.0;
      case WeightUnit.lbs:
        return 5.0;
    }
  }

  double get maxWeight {
    switch (this) {
      case WeightUnit.kg:
        return 1000.0;
      case WeightUnit.lbs:
        return 2204.62;
    }
  }
}

const double _kgToLbsFactor = 2.20462;

double kgToLbs(double kg) => kg * _kgToLbsFactor;

double lbsToKg(double lbs) => lbs / _kgToLbsFactor;
