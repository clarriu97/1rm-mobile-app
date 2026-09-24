import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/weight_unit.dart';
import '../../utils/formulas.dart';
import '../theme/app_theme.dart';

/// A weight that counts up from zero when it first appears and from the old
/// value when it changes (a new PR). Screen readers get only the final value;
/// with reduced motion it just shows it.
class CountingWeight extends StatelessWidget {
  const CountingWeight({
    super.key,
    required this.weightInKg,
    required this.unit,
    this.style,
  });

  final double weightInKg;
  final WeightUnit unit;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: formatWeight(weightInKg, unit, locale: locale),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduceMotion ? weightInKg : 0, end: weightInKg),
        duration: reduceMotion ? Duration.zero : AppMotion.long,
        curve: AppMotion.curve,
        builder: (context, value, _) =>
            Text(formatWeight(value, unit, locale: locale), style: style),
      ),
    );
  }
}
