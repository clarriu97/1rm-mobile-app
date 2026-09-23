import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../utils/formulas.dart';
import 'theme/app_theme.dart';
import 'save_error.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.template,
    required this.records,
    required this.unit,
  });

  final ExerciseTemplate template;
  final RecordsRepository records;
  final WeightUnit unit;

  Future<void> _delete(BuildContext context, ExerciseRecord record) async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text(
          '${formatWeight(record.weight, unit, 0)} × ${record.reps} reps\n'
          '1RM: ${formatWeight(record.oneRM, unit)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await records.delete(template.id, record);
    } on Exception {
      if (context.mounted) showSaveError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              template.assetPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${template.name} History'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: records,
        builder: (context, _) {
          final sorted = List<ExerciseRecord>.from(
            records.recordsFor(template.id),
          )..sort((a, b) => b.date.compareTo(a.date));

          final prs = records.personalRecordsFor(template.id);

          if (sorted.isEmpty) {
            return Center(
              child: Text(
                'No records yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, index) => _buildEntry(
              context,
              sorted[index],
              prs.contains(sorted[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntry(BuildContext context, ExerciseRecord record, bool isPR) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.md);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onLongPress: () => _delete(context, record),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${formatWeight(record.weight, unit)} × ${record.reps} reps',
                              style: text.titleMedium,
                            ),
                          ),
                          if (isPR) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const _PrBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1RM: ${formatWeight(record.oneRM, unit)}',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(_formatDate(record.date), style: text.bodySmall),
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: kMinTapTarget,
                    minHeight: kMinTapTarget,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => _delete(context, record),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

class _PrBadge extends StatelessWidget {
  const _PrBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('pr-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        'PR',
        semanticsLabel: 'Personal record',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
