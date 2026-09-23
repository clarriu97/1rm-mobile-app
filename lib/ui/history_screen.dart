import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../utils/dates.dart';
import '../utils/formulas.dart';
import 'add_entry_screen.dart';
import 'save_error.dart';
import 'theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
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

  Future<void> _edit(BuildContext context, ExerciseRecord record) async {
    final updated = await Navigator.of(context).push<ExerciseRecord>(
      MaterialPageRoute<ExerciseRecord>(
        builder: (context) => AddEntryScreen(
          exerciseName: template.name,
          assetPath: template.assetPath,
          unit: unit,
          initial: record,
          clock: clock,
        ),
      ),
    );
    if (updated == null) return;
    try {
      await records.update(template.id, record, updated);
    } on Exception {
      if (context.mounted) showSaveError(context);
    }
  }

  Future<void> _delete(BuildContext context, ExerciseRecord record) async {
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await records.delete(template.id, record);
    } on Exception {
      if (context.mounted) showSaveError(context);
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Deleted ${formatWeight(record.weight, unit)} × ${record.reps}',
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.accent,
            onPressed: () => records.add(template.id, record),
          ),
        ),
      );
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
            Flexible(
              child: Text(
                '${template.name} History',
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

          final localizations = MaterialLocalizations.of(context);
          final now = clock();
          final children = <Widget>[];
          String? currentMonth;
          for (final record in sorted) {
            final month = localizations.formatMonthYear(record.date);
            if (month != currentMonth) {
              currentMonth = month;
              children.add(_MonthHeader(month.toUpperCase()));
            }
            children.add(
              _HistoryEntry(
                key: ObjectKey(record),
                record: record,
                unit: unit,
                isPR: prs.contains(record),
                dateLabel: _dateLabel(localizations, record.date, now),
                onTap: () => _edit(context, record),
                onDelete: () => _delete(context, record),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: children,
          );
        },
      ),
    );
  }

  static String _dateLabel(
    MaterialLocalizations localizations,
    DateTime date,
    DateTime now,
  ) {
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    return days < 7
        ? formatRelativeDate(date, now)
        : localizations.formatShortMonthDay(date);
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({
    super.key,
    required this.record,
    required this.unit,
    required this.isPR,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
  });

  final ExerciseRecord record;
  final WeightUnit unit;
  final bool isPR;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.md);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ObjectKey(record),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: radius,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.onAccent,
          ),
        ),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.outline),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${formatWeight(record.weight, unit)} × ${record.reps} reps',
                              style: text.titleMedium,
                            ),
                            if (isPR) const _PrBadge(),
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
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: text.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: kMinTapTarget,
                      minHeight: kMinTapTarget,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.textMuted,
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
