import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      illustration: 'assets/illustrations/onboarding_max.svg',
      title: 'What is 1RM?',
      description:
          'Your One-Rep Max is the maximum weight you can lift for a single repetition. It\'s the gold standard for measuring strength.',
    ),
    _OnboardingPage(
      illustration: 'assets/illustrations/onboarding_log.svg',
      title: 'Log your lifts',
      description:
          'Enter any weight and reps you\'ve lifted. We\'ll calculate your estimated 1RM using the Epley formula — no need to attempt a true max.',
    ),
    _OnboardingPage(
      illustration: 'assets/illustrations/onboarding_table.svg',
      title: 'Train smarter',
      description:
          'Get a personalized percentage table based on your best 1RM. Know exactly what weight to use for every training intensity.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: _pages,
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
                      _pages.length,
                      (index) => _PageIndicator(active: index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('onboarding-next-button'),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      key: const Key('onboarding-skip-button'),
                      onPressed: widget.onComplete,
                      child: const Text('Skip'),
                    ),
                  ],
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
  });

  /// Pre-colored SVG; not tinted.
  final String illustration;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KnurlPanel(
            borderColor: AppColors.accent,
            child: SvgPicture.asset(illustration, width: 144, height: 144),
          ),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: text.displayMedium),
          const SizedBox(height: AppSpacing.lg),
          Text(description, textAlign: TextAlign.center, style: text.bodyLarge),
        ],
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
