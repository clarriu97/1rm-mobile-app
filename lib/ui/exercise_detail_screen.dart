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

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.template,
    required this.records,
    required this.unit,
  });

  final ExerciseTemplate template;
  final RecordsRepository records;
  final WeightUnit unit;

  Future<void> _addEntry(BuildContext context) async {
    final record = await Navigator.of(context).push<ExerciseRecord>(
      MaterialPageRoute<ExerciseRecord>(
        builder: (context) => AddEntryScreen(
          exerciseName: template.name,
          assetPath: template.assetPath,
          unit: unit,
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
        builder: (context) =>
            HistoryScreen(template: template, records: records, unit: unit),
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
                  96,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (best != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildBestOneRM(context, best, latest),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildPercentageTable(context, best),
                    ] else ...[
                      const SizedBox(height: 40),
                      _buildEmptyState(context),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addEntry(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Entry'),
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

  Widget _buildPercentageTable(BuildContext context, double best) {
    final text = Theme.of(context).textTheme;
    final table = generatePercentageTable(best, unit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Working weights', style: text.titleMedium),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            children: [
              _buildTableHeader(context),
              for (final entry in table) _buildTableRow(context, entry),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text('PERCENTAGE', style: style)),
          Expanded(
            child: Text('WEIGHT', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, PercentageEntry entry) {
    final isHundred = entry.percentage == 100;
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: isHundred ? AppColors.accent : AppColors.textPrimary,
      fontWeight: isHundred ? FontWeight.w700 : FontWeight.w500,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('${entry.percentage}%', style: style)),
          Expanded(
            child: Text(
              formatWeight(entry.weight, unit),
              textAlign: TextAlign.right,
              style: style,
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
