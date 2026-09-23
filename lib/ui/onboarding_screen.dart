import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/weight_unit.dart';
import 'theme/app_theme.dart';

/// Countries that don't use the metric system for weights in the gym.
const _poundCountries = {'US', 'LR', 'MM'};

/// Sensible first unit for a device region; kg when unknown.
WeightUnit defaultUnitForCountry(String? countryCode) =>
    _poundCountries.contains(countryCode?.toUpperCase())
    ? WeightUnit.lbs
    : WeightUnit.kg;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.initialUnit = WeightUnit.kg,
  });

  /// Called with the unit chosen on the last page (or [initialUnit] when
  /// the user skips).
  final ValueChanged<WeightUnit> onComplete;
  final WeightUnit initialUnit;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  late WeightUnit _unit = widget.initialUnit;

  static const _pageCount = 3;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  void _nextPage() {
    if (_isLastPage) {
      widget.onComplete(_unit);
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
    final pages = [
      const _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_max.svg',
        title: 'What is 1RM?',
        description:
            'Your One-Rep Max: the heaviest weight you can lift once. '
            'The baseline for all your training.',
      ),
      const _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_log.svg',
        title: 'Log your lifts',
        description:
            'Enter any set — weight × reps. The Epley formula estimates '
            'your max, no need to test it.',
      ),
      _OnboardingPage(
        illustration: 'assets/illustrations/onboarding_table.svg',
        title: 'Train smarter',
        description:
            'Get working weights for every percentage and rep range. '
            'Which unit do you lift in?',
        footer: _UnitChoice(
          selected: _unit,
          onChanged: (unit) => setState(() => _unit = unit),
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
                      onPressed: _nextPage,
                      child: Text(_isLastPage ? 'Get Started' : 'Next'),
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
                      onPressed: () => widget.onComplete(_unit),
                      child: const Text('Skip'),
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
      label: unit == WeightUnit.kg ? 'Kilograms' : 'Pounds',
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
