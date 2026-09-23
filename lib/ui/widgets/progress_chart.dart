import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../models/weight_unit.dart';
import '../../utils/formulas.dart';
import '../theme/app_theme.dart';
import 'segmented_chips.dart';

enum ProgressRange {
  threeMonths('3M'),
  year('1Y'),
  all('ALL');

  const ProgressRange(this.label);

  final String label;

  /// First day included in the range, or null for everything.
  DateTime? startFrom(DateTime now) => switch (this) {
    ProgressRange.threeMonths => DateTime(now.year, now.month - 3, now.day),
    ProgressRange.year => DateTime(now.year - 1, now.month, now.day),
    ProgressRange.all => null,
  };
}

/// Records inside [range], oldest first.
List<ExerciseRecord> recordsInRange(
  Iterable<ExerciseRecord> records,
  ProgressRange range,
  DateTime now,
) {
  final start = range.startFrom(now);
  return records.where((r) => start == null || !r.date.isBefore(start)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

/// Chart-space points: x in days since the first record, y in [unit].
List<FlSpot> progressSpots(
  List<ExerciseRecord> chronological,
  WeightUnit unit,
) {
  if (chronological.isEmpty) return const [];
  final origin = chronological.first.date;
  return [
    for (final r in chronological)
      FlSpot(
        r.date.difference(origin).inMinutes / Duration.minutesPerDay,
        unit == WeightUnit.lbs ? kgToLbs(r.oneRM) : r.oneRM,
      ),
  ];
}

/// Round step for about [targetLines] grid lines: 1, 2, 2.5 or 5 × 10ⁿ.
double niceStep(double range, {int targetLines = 3}) {
  if (range <= 0) return 1;
  final raw = range / targetLines;
  final magnitude = math
      .pow(10, (math.log(raw) / math.ln10).floor())
      .toDouble();
  for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (raw <= m * magnitude) return m * magnitude;
  }
  return 10 * magnitude;
}

/// Y bounds with breathing room, snapped to a round [step] so grid labels
/// are clean numbers that never collide with the edges.
({double min, double max, double step}) progressYBounds(List<FlSpot> spots) {
  final ys = spots.map((s) => s.y);
  final low = ys.reduce(math.min);
  final high = ys.reduce(math.max);
  final pad = math.max((high - low) * 0.15, 2.5);
  final step = niceStep(high - low + 2 * pad);
  return (
    min: math.max(0, ((low - pad) / step).floor() * step),
    max: ((high + pad) / step).ceil() * step,
    step: step,
  );
}

class ProgressChart extends StatefulWidget {
  const ProgressChart({
    super.key,
    required this.records,
    required this.personalRecords,
    required this.unit,
    required this.now,
  });

  final List<ExerciseRecord> records;
  final Set<ExerciseRecord> personalRecords;
  final WeightUnit unit;
  final DateTime now;

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  ProgressRange _range = ProgressRange.all;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final inRange = recordsInRange(widget.records, _range, widget.now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Progress', style: text.titleMedium)),
            SegmentedChips<ProgressRange>(
              values: ProgressRange.values,
              selected: _range,
              labelOf: (range) => range.label,
              onSelected: (range) => setState(() => _range = range),
              keyPrefix: 'range',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.outline),
          ),
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: widget.records.length < 2
                  ? const _ChartMessage(
                      'Log at least two sessions to see your progress.',
                    )
                  : inRange.length < 2
                  ? const _ChartMessage('Not enough entries in this range.')
                  : _buildChart(context, inRange),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<ExerciseRecord> points) {
    final text = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final spots = progressSpots(points, widget.unit);
    final bounds = progressYBounds(spots);
    final maxX = spots.last.x == spots.first.x
        ? spots.first.x + 1
        : spots.last.x;
    final labelStyle = text.bodySmall;
    final first = formatWeight(points.first.oneRM, widget.unit);
    final last = formatWeight(points.last.oneRM, widget.unit);

    return Semantics(
      label:
          'Progress chart: 1RM from $first to $last over ${points.length} entries',
      child: ExcludeSemantics(
        child: LineChart(
          key: const Key('progress-line-chart'),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 250),
          LineChartData(
            minX: spots.first.x,
            maxX: maxX,
            minY: bounds.min,
            maxY: bounds.max,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: bounds.step,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.outline, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: bounds.step,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(value.toStringAsFixed(0), style: labelStyle),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: maxX - spots.first.x,
                  getTitlesWidget: (value, meta) {
                    final isFirst = value == meta.min;
                    if (!isFirst && value != meta.max) return const SizedBox();
                    final date = isFirst ? points.first.date : points.last.date;
                    return SideTitleWidget(
                      meta: meta,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(
                        localizations.formatShortMonthDay(date),
                        style: labelStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.surfaceRaised,
                tooltipBorder: const BorderSide(color: AppColors.outline),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                maxContentWidth: 180,
                getTooltipItems: (touched) => [
                  for (final spot in touched)
                    LineTooltipItem(
                      '${localizations.formatShortMonthDay(points[spot.spotIndex].date)}\n',
                      labelStyle!,
                      children: [
                        TextSpan(
                          text: formatWeight(
                            points[spot.spotIndex].oneRM,
                            widget.unit,
                          ),
                          style: text.titleSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: AppColors.accent,
                barWidth: 2.5,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.18),
                      AppColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
                dotData: FlDotData(
                  getDotPainter: (spot, _, _, index) {
                    final isPR = widget.personalRecords.contains(points[index]);
                    return FlDotCirclePainter(
                      radius: isPR ? 5 : 3,
                      color: isPR ? AppColors.accent : AppColors.textSecondary,
                      strokeWidth: isPR ? 2 : 0,
                      strokeColor: AppColors.surface,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
