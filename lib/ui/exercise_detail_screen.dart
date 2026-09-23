import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../utils/formulas.dart';
import 'add_entry_screen.dart';
import 'theme/app_theme.dart';
import 'history_screen.dart';
import 'save_error.dart';
import 'widgets/pr_celebration.dart';
import 'widgets/progress_chart.dart';
import 'widgets/segmented_chips.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.template,
    required this.records,
    required this.unit,
    this.clock = DateTime.now,
  });

  final ExerciseTemplate template;
  final RecordsRepository records;
  final WeightUnit unit;
  final DateTime Function() clock;

  Future<void> _addEntry(BuildContext context) async {
    final record = await Navigator.of(context).push<ExerciseRecord>(
      MaterialPageRoute<ExerciseRecord>(
        builder: (context) => AddEntryScreen(
          exerciseName: template.name,
          assetPath: template.assetPath,
          unit: unit,
          clock: clock,
        ),
      ),
    );

    if (record == null) return;
    final previousBest = records.bestOneRMFor(template.id);
    final bool isPR;
    try {
      isPR = await records.add(template.id, record);
    } on Exception {
      if (context.mounted) showSaveError(context);
      return;
    }
    if (isPR && context.mounted) {
      await showPrCelebration(
        context,
        exerciseName: template.name,
        oneRM: record.oneRM,
        previousBest: previousBest!,
        unit: unit,
      );
    }
  }

  Future<void> _openHistory(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => HistoryScreen(
          template: template,
          records: records,
          unit: unit,
          clock: clock,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: records,
      builder: (context, _) {
        final best = records.bestOneRMFor(template.id);
        final latest = records.latestFor(template.id);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  template.assetPath,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(template.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
              if (best != null)
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'History',
                  onPressed: () => _openHistory(context),
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (best != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildBestOneRM(context, best, latest),
                      const SizedBox(height: AppSpacing.xxl),
                      ProgressChart(
                        records: records.recordsFor(template.id),
                        personalRecords: records.personalRecordsFor(
                          template.id,
                        ),
                        unit: unit,
                        now: clock(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _WorkingWeights(
                        oneRM: unit == WeightUnit.lbs ? kgToLbs(best) : best,
                        unit: unit,
                      ),
                    ] else ...[
                      const SizedBox(height: 40),
                      _buildEmptyState(context),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: ElevatedButton.icon(
              key: const Key('add-entry-button'),
              onPressed: () => _addEntry(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Entry'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBestOneRM(
    BuildContext context,
    double best,
    ExerciseRecord? latest,
  ) {
    final text = Theme.of(context).textTheme;
    return KnurlPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HazardStripe(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('BEST 1RM', style: text.labelMedium),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatWeight(best, unit),
                    style: text.displayLarge?.copyWith(color: AppColors.accent),
                  ),
                ),
                if (latest != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Latest: ${formatWeight(latest.weight, unit)} × ${latest.reps} reps → ${formatWeight(latest.oneRM, unit)}',
                            style: text.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              template.assetPath,
              width: 72,
              height: 72,
              colorFilter: const ColorFilter.mode(
                AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No records yet', style: text.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tap "Add Entry" to log your first\ntraining data for this exercise.',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

enum _TableMode { percent, reps }

/// Working weights by percentage or by reps. [oneRM] is in [unit] so the
/// rounding lands on plates you can actually load.
class _WorkingWeights extends StatefulWidget {
  const _WorkingWeights({required this.oneRM, required this.unit});

  final double oneRM;
  final WeightUnit unit;

  @override
  State<_WorkingWeights> createState() => _WorkingWeightsState();
}

class _WorkingWeightsState extends State<_WorkingWeights> {
  _TableMode _mode = _TableMode.percent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rows = _mode == _TableMode.percent
        ? [
            for (final e in generatePercentageTable(widget.oneRM, widget.unit))
              (
                label: '${e.percentage}%',
                weight: e.weight,
                top: e.percentage == 100,
              ),
          ]
        : [
            for (final e in generateRepsTable(widget.oneRM, widget.unit))
              (
                label: e.reps == 1 ? '1 rep' : '${e.reps} reps',
                weight: e.weight,
                top: e.reps == 1,
              ),
          ];
    final increment = widget.unit.roundingIncrement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Working weights', style: text.titleMedium)),
            SegmentedChips<_TableMode>(
              values: _TableMode.values,
              selected: _mode,
              labelOf: (mode) => mode == _TableMode.percent ? '%' : 'REPS',
              onSelected: (mode) => setState(() => _mode = mode),
              keyPrefix: 'table',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          key: const Key('working-weights-table'),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            children: [
              _TableRow(
                left: _mode == _TableMode.percent ? 'PERCENTAGE' : 'REPS',
                right: 'WEIGHT',
                style: text.labelMedium,
                divider: false,
              ),
              for (final row in rows)
                _TableRow(
                  left: row.label,
                  right: formatUnitValue(row.weight, widget.unit),
                  style: text.titleMedium?.copyWith(
                    color: row.top ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: row.top ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Rounded to the nearest ${increment.toStringAsFixed(0)} ${widget.unit.displayName}.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.left,
    required this.right,
    required this.style,
    this.divider = true,
  });

  final String left;
  final String right;
  final TextStyle? style;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: divider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outline)),
            )
          : null,
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Expanded(
            child: Text(right, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}
