import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/app_language.dart';
import '../models/weight_unit.dart';
import '../repositories/language_repository.dart';
import '../services/unit_service.dart';
import 'theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.unitService,
    required this.currentUnit,
    required this.language,
  });

  final UnitService unitService;
  final WeightUnit currentUnit;
  final LanguageRepository language;

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
    final l10n = AppLocalizations.of(context);
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.units, style: titleStyle),
          const SizedBox(height: AppSpacing.md),
          _ChoiceGroup(
            children: [
              for (final unit in WeightUnit.values)
                _ChoiceTile(
                  key: Key('unit-${unit.name}'),
                  label: unit.displayName,
                  isSelected: _unit == unit,
                  onTap: () => _onUnitChanged(unit),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.language, style: titleStyle),
          const SizedBox(height: AppSpacing.md),
          ListenableBuilder(
            listenable: widget.language,
            builder: (context, _) => _ChoiceGroup(
              children: [
                for (final language in AppLanguage.values)
                  _ChoiceTile(
                    key: Key('language-${language.name}'),
                    label: switch (language) {
                      AppLanguage.system => l10n.languageSystem,
                      AppLanguage.en => l10n.languageEnglish,
                      AppLanguage.es => l10n.languageSpanish,
                    },
                    isSelected: widget.language.language == language,
                    onTap: () => widget.language.setLanguage(language),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) Container(height: 0.5, color: AppColors.outline),
            child,
          ],
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
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
                    label,
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
      ),
    );
  }
}
