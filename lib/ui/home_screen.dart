import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/weight_unit.dart';
import '../repositories/records_repository.dart';
import '../services/unit_service.dart';
import '../utils/formulas.dart';
import 'exercise_detail_screen.dart';
import 'settings_screen.dart';
import 'theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.records,
    required this.unitService,
  });

  final RecordsRepository records;
  final UnitService unitService;

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
        builder: (context) =>
            SettingsScreen(unitService: widget.unitService, currentUnit: _unit),
      ),
    );
    _loadUnit();
  }

  Future<void> _openDetail(ExerciseTemplate template) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ExerciseDetailScreen(
          template: template,
          records: widget.records,
          unit: _unit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1RM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.records,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                80,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final template = defaultExercises[index];
                  return _ExerciseCard(
                    template: template,
                    bestOneRM: widget.records.bestOneRMFor(template.id),
                    unit: _unit,
                    onTap: () => _openDetail(template),
                  );
                }, childCount: defaultExercises.length),
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
    required this.bestOneRM,
    required this.unit,
    required this.onTap,
  });

  final ExerciseTemplate template;
  final double? bestOneRM;
  final WeightUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = bestOneRM != null;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.md);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: hasData ? AppColors.surfaceRaised : AppColors.surface,
            borderRadius: radius,
            border: Border.all(
              color: hasData ? AppColors.accent : AppColors.outline,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                template.assetPath,
                width: 40,
                height: 40,
                colorFilter: ColorFilter.mode(
                  hasData ? AppColors.accent : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                template.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(fontSize: 13, height: 1.2),
              ),
              if (hasData) ...[
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatWeight(bestOneRM!, unit),
                    style: text.displaySmall?.copyWith(
                      fontSize: 22,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
