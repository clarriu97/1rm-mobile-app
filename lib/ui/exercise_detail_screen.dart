import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../utils/formulas.dart';
import 'add_entry_screen.dart';
import 'app_theme.dart';
import 'history_screen.dart';
import 'save_error.dart';

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
    try {
      await records.add(template.id, record);
    } on Exception {
      if (context.mounted) showSaveError(context);
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
                const SizedBox(width: 8),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (best != null) ...[
                      const SizedBox(height: 8),
                      _buildBestOneRM(context, best, latest),
                      const SizedBox(height: 24),
                      _buildPercentageTable(context, best),
                      const SizedBox(height: 24),
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
            backgroundColor: AppColors.cta,
            foregroundColor: AppColors.background,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Entry'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cta.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Best 1RM',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: AppColors.cta,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatWeight(best, unit),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.cta,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (latest != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Latest: ${formatWeight(latest.weight, unit)} × ${latest.reps} reps → ${formatWeight(latest.oneRM, unit)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPercentageTable(BuildContext context, double best) {
    final table = generatePercentageTable(best, unit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Working weights', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(60),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [_buildTableHeader(), ...table.map(_buildTableRow)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface.withAlpha(100)),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Percentage',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Weight',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(PercentageEntry entry) {
    final isHundred = entry.percentage == 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.textMuted.withAlpha(20), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${entry.percentage}%',
              style: TextStyle(
                color: isHundred ? AppColors.cta : AppColors.textPrimary,
                fontWeight: isHundred ? FontWeight.w700 : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formatWeight(entry.weight, unit),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHundred ? AppColors.cta : AppColors.textPrimary,
                fontWeight: isHundred ? FontWeight.w700 : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              template.assetPath,
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppColors.accent.withAlpha(100),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No records yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap "Add Entry" to log your first\ntraining data for this exercise.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
