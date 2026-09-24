import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_names.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../utils/dates.dart';
import '../utils/formulas.dart';
import 'add_entry_screen.dart';
import 'save_error.dart';
import 'theme/app_theme.dart';
import 'undo_snack_bar.dart';
import 'widgets/staggered_list.dart';

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
    final exerciseName = AppLocalizations.of(context).exerciseName(template);
    final updated = await Navigator.of(context).push<ExerciseRecord>(
      MaterialPageRoute<ExerciseRecord>(
        builder: (context) => AddEntryScreen(
          exerciseName: exerciseName,
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
    final l10n = AppLocalizations.of(context);
    try {
      await records.delete(template.id, record);
    } on Exception {
      if (context.mounted) showSaveError(context);
      return;
    }
    if (!context.mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.deletedSet(
        l10n.set(
          formatWeight(record.weight, unit, locale: l10n.localeName),
          record.reps,
        ),
      ),
      onUndo: () => records.add(template.id, record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              template.assetPath,
              excludeFromSemantics: true,
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
                l10n.historyTitle(l10n.exerciseName(template)),
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
                l10n.noRecordsYet,
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
                dateLabel: _dateLabel(localizations, l10n, record.date, now),
                onTap: () => _edit(context, record),
                onDelete: () => _delete(context, record),
              ),
            );
          }

          return StaggeredList(
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
    AppLocalizations l10n,
    DateTime date,
    DateTime now,
  ) {
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    return days < 7
        ? formatRelativeDate(date, now, l10n)
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
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
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
          child: Semantics(
            onTapHint: l10n.editHint,
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
                                l10n.set(
                                  formatWeight(
                                    record.weight,
                                    unit,
                                    locale: locale,
                                  ),
                                  record.reps,
                                ),
                                style: text.titleMedium,
                              ),
                              if (isPR) const _PrBadge(),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.oneRmValue(
                              formatWeight(record.oneRM, unit, locale: locale),
                            ),
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
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                    ),
                  ],
                ),
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
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('pr-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        l10n.prBadge,
        semanticsLabel: l10n.personalRecord,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
