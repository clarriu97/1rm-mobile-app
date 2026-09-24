import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_names.dart';
import '../models/weight_unit.dart';
import '../repositories/exercise_library.dart';
import '../repositories/language_repository.dart';
import '../repositories/records_repository.dart';
import '../services/unit_service.dart';
import '../utils/dates.dart';
import '../utils/formulas.dart';
import 'exercise_detail_screen.dart';
import 'manage_exercises_screen.dart';
import 'settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/sparkline.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.records,
    required this.library,
    required this.unitService,
    required this.language,
    this.clock = DateTime.now,
  });

  final RecordsRepository records;
  final ExerciseLibrary library;
  final UnitService unitService;
  final LanguageRepository language;
  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeightUnit _unit = WeightUnit.kg;

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final unit = await widget.unitService.getUnit();
    if (mounted) setState(() => _unit = unit);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          unitService: widget.unitService,
          currentUnit: _unit,
          language: widget.language,
        ),
      ),
    );
    _loadUnit();
  }

  Future<void> _openLibrary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ManageExercisesScreen(
          library: widget.library,
          records: widget.records,
        ),
      ),
    );
  }

  Future<void> _openDetail(ExerciseTemplate template) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ExerciseDetailScreen(
          template: template,
          records: widget.records,
          unit: _unit,
          clock: widget.clock,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('1RM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: l10n.settings,
            onPressed: _openSettings,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([widget.records, widget.library]),
        builder: (context, _) {
          final now = widget.clock();
          final exercises = widget.library.visible;
          final hasAnyRecord = exercises.any(
            (e) => widget.records.latestFor(e.id) != null,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              if (exercises.isEmpty)
                const _AllHiddenHint()
              else if (!hasAnyRecord)
                const _FirstLiftHint(),
              for (final template in exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ExerciseCard(
                    template: template,
                    records: widget.records,
                    unit: _unit,
                    now: now,
                    onTap: () => _openDetail(template),
                  ),
                ),
              Center(
                child: TextButton.icon(
                  key: const Key('manage-exercises-button'),
                  onPressed: _openLibrary,
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  label: Text(l10n.manageExercises),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AllHiddenHint extends StatelessWidget {
  const _AllHiddenHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Text(
        AppLocalizations.of(context).allExercisesHidden,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _FirstLiftHint extends StatelessWidget {
  const _FirstLiftHint();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: KnurlPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HazardStripe(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.firstLiftTitle, style: text.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l10n.firstLiftBody, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.template,
    required this.records,
    required this.unit,
    required this.now,
    required this.onTap,
  });

  final ExerciseTemplate template;
  final RecordsRepository records;
  final WeightUnit unit;
  final DateTime now;
  final VoidCallback onTap;

  static const _trendLength = 12;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final best = records.bestOneRMFor(template.id);
    final latest = records.latestFor(template.id);
    final hasData = best != null;
    final trend = (List.of(
      records.recordsFor(template.id),
    )..sort((a, b) => a.date.compareTo(b.date))).map((r) => r.oneRM).toList();
    final radius = BorderRadius.circular(AppRadii.md);
    final name = l10n.exerciseName(template);
    final locale = l10n.localeName;

    return Semantics(
      button: true,
      label: best == null || latest == null
          ? l10n.exerciseCardEmptySemantics(name)
          : l10n.exerciseCardSemantics(
              name,
              formatWeight(best, unit, locale: locale),
              formatRelativeDate(latest.date, now, l10n),
            ),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: hasData ? AppColors.surfaceRaised : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: hasData ? AppColors.accent : AppColors.outline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    template.assetPath,
                    excludeFromSemantics: true,
                    width: 44,
                    height: 44,
                    colorFilter: ColorFilter.mode(
                      hasData ? AppColors.accent : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          latest == null
                              ? l10n.noRecordsYet
                              : formatRelativeDate(latest.date, now, l10n),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                formatWeight(
                                  best,
                                  unit,
                                  locale: l10n.localeName,
                                ),
                                style: text.displaySmall?.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            if (trend.length >= 2) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Sparkline(
                                values: trend.length > _trendLength
                                    ? trend.sublist(trend.length - _trendLength)
                                    : trend,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
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
