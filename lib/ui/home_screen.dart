import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../services/storage_service.dart';
import '../services/unit_service.dart';
import '../utils/formulas.dart';
import 'exercise_detail_screen.dart';
import 'settings_screen.dart';
import 'app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.initialRecords,
    required this.storage,
    required this.unitService,
  });

  final Map<String, List<ExerciseRecord>> initialRecords;
  final StorageService storage;
  final UnitService unitService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, List<ExerciseRecord>> _records;
  WeightUnit _unit = WeightUnit.kg;

  @override
  void initState() {
    super.initState();
    _records = widget.initialRecords;
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

  Future<void> _persist() => widget.storage.save(_records);

  Future<void> _openDetail(
    String exerciseName,
    ExerciseTemplate template,
  ) async {
    final existingRecords = _records[exerciseName] ?? [];

    final updatedRecords = await Navigator.of(context)
        .push<List<ExerciseRecord>>(
          MaterialPageRoute<List<ExerciseRecord>>(
            builder: (context) => ExerciseDetailScreen(
              template: template,
              records: existingRecords,
              unit: _unit,
            ),
          ),
        );

    if (updatedRecords != null) {
      setState(() {
        if (updatedRecords.isEmpty) {
          _records.remove(exerciseName);
        } else {
          _records[exerciseName] = updatedRecords;
        }
      });
      _persist();
    }
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final template = defaultExercises[index];
                final records = _records[template.name] ?? [];
                final bestOneRM = records.isEmpty
                    ? null
                    : records
                          .map((r) => r.oneRM)
                          .reduce((a, b) => a > b ? a : b);
                return _ExerciseCard(
                  template: template,
                  bestOneRM: bestOneRM,
                  unit: _unit,
                  onTap: () => _openDetail(template.name, template),
                );
              }, childCount: defaultExercises.length),
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasData
                ? AppColors.surface.withAlpha(120)
                : AppColors.surface.withAlpha(60),
            borderRadius: BorderRadius.circular(16),
            border: hasData
                ? Border.all(color: AppColors.cta.withAlpha(60))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                template.assetPath,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  hasData ? AppColors.cta : AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                template.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              if (hasData) ...[
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatWeight(bestOneRM!, unit),
                    style: const TextStyle(
                      color: AppColors.cta,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
