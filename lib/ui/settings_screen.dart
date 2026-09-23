import 'package:flutter/material.dart';
import '../models/weight_unit.dart';
import '../services/unit_service.dart';
import 'theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.unitService,
    required this.currentUnit,
  });

  final UnitService unitService;
  final WeightUnit currentUnit;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late WeightUnit _unit;

  @override
  void initState() {
    super.initState();
    _unit = widget.currentUnit;
  }

  Future<void> _onUnitChanged(WeightUnit? newUnit) async {
    if (newUnit == null || newUnit == _unit) return;
    await widget.unitService.setUnit(newUnit);
    if (mounted) setState(() => _unit = newUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Units', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                _UnitTile(
                  unit: WeightUnit.kg,
                  isSelected: _unit == WeightUnit.kg,
                  onTap: () => _onUnitChanged(WeightUnit.kg),
                ),
                Container(height: 0.5, color: AppColors.outline),
                _UnitTile(
                  unit: WeightUnit.lbs,
                  isSelected: _unit == WeightUnit.lbs,
                  onTap: () => _onUnitChanged(WeightUnit.lbs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  final WeightUnit unit;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  unit.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
