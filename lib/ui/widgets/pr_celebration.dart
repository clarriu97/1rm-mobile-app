import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/weight_unit.dart';
import '../../utils/formulas.dart';
import '../theme/app_theme.dart';

/// How long the celebration stays up unless tapped away.
const Duration kPrCelebrationDuration = Duration(milliseconds: 2500);

/// Shows the "NEW PR" moment: heavy haptic, a panel that pops in (static when
/// the system asks for reduced motion) and closes itself.
Future<void> showPrCelebration(
  BuildContext context, {
  required String exerciseName,
  required double oneRM,
  required double previousBest,
  required WeightUnit unit,
}) {
  HapticFeedback.heavyImpact();
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.background.withValues(alpha: 0.85),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 420),
    pageBuilder: (context, _, _) => PrCelebration(
      exerciseName: exerciseName,
      oneRM: oneRM,
      previousBest: previousBest,
      unit: unit,
    ),
    transitionBuilder: (context, animation, _, child) {
      if (reduceMotion) return child;
      final pop = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(pop),
          child: child,
        ),
      );
    },
  );
}

class PrCelebration extends StatefulWidget {
  const PrCelebration({
    super.key,
    required this.exerciseName,
    required this.oneRM,
    required this.previousBest,
    required this.unit,
  });

  final String exerciseName;
  final double oneRM;
  final double previousBest;
  final WeightUnit unit;

  @override
  State<PrCelebration> createState() => _PrCelebrationState();
}

class _PrCelebrationState extends State<PrCelebration> {
  Timer? _autoClose;

  @override
  void initState() {
    super.initState();
    _autoClose = Timer(kPrCelebrationDuration, _close);
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    super.dispose();
  }

  void _close() {
    _autoClose?.cancel();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final gain = widget.oneRM - widget.previousBest;
    return Semantics(
      liveRegion: true,
      label:
          'New personal record: ${widget.exerciseName}, '
          '${formatWeight(widget.oneRM, widget.unit)}',
      child: GestureDetector(
        onTap: _close,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Material(
              type: MaterialType.transparency,
              child: KnurlPanel(
                key: const Key('pr-celebration'),
                borderColor: AppColors.accent,
                padding: EdgeInsets.zero,
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HazardStripe(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 48,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'NEW PR',
                              style: text.displayMedium?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.exerciseName.toUpperCase(),
                              style: text.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatWeight(widget.oneRM, widget.unit),
                                style: text.displayLarge?.copyWith(
                                  fontSize: 64,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '+${formatWeight(gain, widget.unit)} over your previous best',
                              key: const Key('pr-gain'),
                              textAlign: TextAlign.center,
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
