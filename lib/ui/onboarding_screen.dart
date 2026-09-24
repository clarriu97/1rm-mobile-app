import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_names.dart';
import '../models/weight_unit.dart';
import 'theme/app_theme.dart';

/// Countries that don't use the metric system for weights in the gym.
const _poundCountries = {'US', 'LR', 'MM'};

/// Sensible first unit for a device region; kg when unknown.
WeightUnit defaultUnitForCountry(String? countryCode) =>
    _poundCountries.contains(countryCode?.toUpperCase())
    ? WeightUnit.lbs
    : WeightUnit.kg;

/// What the user chose during onboarding. [lifts] is null when they skipped,
/// so the library keeps its defaults.
typedef OnboardingChoices = ({WeightUnit unit, Set<String>? lifts});

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.initialUnit = WeightUnit.kg,
    this.exercises = defaultExercises,
    this.initialLifts,
  });

  final ValueChanged<OnboardingChoices> onComplete;
  final WeightUnit initialUnit;

  /// Lifts offered on the "Pick your lifts" page.
  final List<ExerciseTemplate> exercises;

  /// Preselected lifts; defaults to the exercises visible by default.
  final Set<String>? initialLifts;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  late WeightUnit _unit = widget.initialUnit;
  late final Set<String> _lifts =
      widget.initialLifts ??
      {
        for (final e in widget.exercises)
          if (e.defaultVisible) e.id,
      };

  static const _pageCount = 4;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  void _nextPage() {
    if (_isLastPage) {
      widget.onComplete((unit: _unit, lifts: Set.of(_lifts)));
      return;
    }
    _controller.nextPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_max.svg',
        title: l10n.onboardingWhatTitle,
        description: l10n.onboardingWhatBody,
      ),
      _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_log.svg',
        title: l10n.onboardingLogTitle,
        description: l10n.onboardingLogBody,
      ),
      _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_table.svg',
        title: l10n.onboardingTrainTitle,
        description: l10n.onboardingTrainBody,
        footer: _UnitChoice(
          selected: _unit,
          onChanged: (unit) => setState(() => _unit = unit),
        ),
      ),
      _PickLiftsPage(
        exercises: widget.exercises,
        selected: _lifts,
        onToggle: (id) => setState(
          () => _lifts.contains(id) ? _lifts.remove(id) : _lifts.add(id),
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
                      (index) => _PageIndicator(active: index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('onboarding-next-button'),
                      onPressed: _isLastPage && _lifts.isEmpty
                          ? null
                          : _nextPage,
                      child: Text(
                        !_isLastPage
                            ? l10n.next
                            : _lifts.isEmpty
                            ? l10n.pickAtLeastOneLift
                            : l10n.getStarted,
                      ),
                    ),
                  ),
                  // Keep the layout stable: reserve the Skip slot on the
                  // last page too.
                  const SizedBox(height: AppSpacing.md),
                  Visibility(
                    visible: !_isLastPage,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      key: const Key('onboarding-skip-button'),
                      onPressed: () =>
                          widget.onComplete((unit: _unit, lifts: null)),
                      child: Text(l10n.skip),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.illustration,
    required this.title,
    required this.description,
    this.footer,
  });

  /// Pre-colored SVG; not tinted.
  final String illustration;
  final String title;
  final String description;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KnurlPanel(
              borderColor: AppColors.accent,
              child: SvgPicture.asset(illustration, width: 128, height: 128),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(title, textAlign: TextAlign.center, style: text.displayMedium),
            const SizedBox(height: AppSpacing.lg),
            Text(
              description,
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.xl),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _PickLiftsPage extends StatelessWidget {
  const _PickLiftsPage({
    required this.exercises,
    required this.selected,
    required this.onToggle,
  });

  final List<ExerciseTemplate> exercises;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Fade the bottom edge so it's obvious the list keeps going.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          AppColors.background,
          AppColors.background.withValues(alpha: 0),
        ],
        stops: const [0, 0.9, 1],
      ).createShader(bounds),
      child: _buildList(text, AppLocalizations.of(context)),
    );
  }

  Widget _buildList(TextTheme text, AppLocalizations l10n) {
    return ListView(
      key: const Key('pick-lifts-page'),
      // Extra bottom room so the last row clears the fade when scrolled.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl * 2,
      ),
      children: [
        Text(
          l10n.pickLiftsTitle,
          textAlign: TextAlign.center,
          style: text.displayMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.pickLiftsBody,
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.selectedCount(selected.length),
          key: const Key('pick-lifts-count'),
          textAlign: TextAlign.center,
          style: text.labelMedium?.copyWith(color: AppColors.accent),
        ),
        for (final (category, group) in groupByCategory(exercises)) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.categoryName(category).toUpperCase(),
            style: text.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final exercise in group)
                _LiftChip(
                  exercise: exercise,
                  selected: selected.contains(exercise.id),
                  onTap: () => onToggle(exercise.id),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LiftChip extends StatelessWidget {
  const _LiftChip({
    required this.exercise,
    required this.selected,
    required this.onTap,
  });

  final ExerciseTemplate exercise;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onAccent : AppColors.textPrimary;
    final radius = BorderRadius.circular(AppRadii.sm);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.accent : AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.outline,
          ),
        ),
        child: InkWell(
          key: Key('lift-chip-${exercise.id}'),
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    exercise.assetPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).exerciseName(exercise),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: foreground),
                    ),
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

class _UnitChoice extends StatelessWidget {
  const _UnitChoice({required this.selected, required this.onChanged});

  final WeightUnit selected;
  final ValueChanged<WeightUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final unit in WeightUnit.values) ...[
          if (unit != WeightUnit.values.first)
            const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _UnitOption(
              unit: unit,
              selected: unit == selected,
              onTap: () => onChanged(unit),
            ),
          ),
        ],
      ],
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  final WeightUnit unit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    return Semantics(
      selected: selected,
      button: true,
      label: unit == WeightUnit.kg
          ? AppLocalizations.of(context).kilograms
          : AppLocalizations.of(context).pounds,
      child: Material(
        color: selected ? AppColors.accent : AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.outline,
          ),
        ),
        child: InkWell(
          key: Key('unit-option-${unit.name}'),
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: 64,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  unit.displayName.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: selected
                        ? AppColors.onAccent
                        : AppColors.textPrimary,
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

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: active ? 28 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.outline,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
    );
  }
}
