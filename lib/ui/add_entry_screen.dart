import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../utils/dates.dart';
import '../utils/formulas.dart';
import 'theme/app_theme.dart';

/// Form route for a new entry, or for editing [initial]. Pops the resulting
/// [ExerciseRecord] (weights in kg), or nothing when dismissed.
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.exerciseName,
    required this.assetPath,
    required this.unit,
    this.initial,
    this.clock = DateTime.now,
  });

  final String exerciseName;
  final String assetPath;
  final WeightUnit unit;
  final ExerciseRecord? initial;
  final DateTime Function() clock;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _repsFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _date = initial?.date ?? widget.clock();
    if (initial != null) {
      final weight = widget.unit == WeightUnit.lbs
          ? kgToLbs(initial.weight)
          : initial.weight;
      _weightController.text = _trimZeros(weight);
      _repsController.text = '${initial.reps}';
    }
    _weightController.addListener(_onChanged);
    _repsController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  static String _trimZeros(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Future<void> _pickDate() async {
    final today = widget.clock();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    // Keep the time of day so entries on the same day stay in order.
    final time = _isEditing ? widget.initial!.date : today;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
        time.second,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final displayWeight = parseWeight(_weightController.text.trim());
    final weightInKg = widget.unit == WeightUnit.lbs
        ? lbsToKg(displayWeight)
        : displayWeight;
    final reps = int.parse(_repsController.text.trim());

    Navigator.of(context).pop(
      ExerciseRecord(
        weight: weightInKg,
        reps: reps,
        oneRM: calculateOneRM(weightInKg, reps),
        date: _date,
      ),
    );
  }

  String? _validateWeight(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.required;
    final v = tryParseWeight(value.trim());
    if (v == null || v <= 0) return l10n.invalid;
    if (v > widget.unit.maxWeight) {
      return l10n.maxWeight(
        formatUnitValue(
          widget.unit.maxWeight,
          widget.unit,
          locale: l10n.localeName,
        ),
      );
    }
    return null;
  }

  String? _validateReps(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.required;
    final v = int.tryParse(value.trim());
    if (v == null || v <= 0) return l10n.invalid;
    if (v > maxReps) return l10n.maxReps(maxReps);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final inputStyle = text.headlineMedium?.copyWith(fontSize: 30);
    final estimate = estimateOneRMFromInput(
      _weightController.text,
      _repsController.text,
      widget.unit,
    );
    final reps = int.tryParse(_repsController.text.trim());
    final highReps = reps != null && reps > accurateRepsLimit;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              widget.assetPath,
              excludeFromSemantics: true,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(widget.exerciseName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? l10n.editEntry : l10n.enterYourLift,
                style: text.labelMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: l10n.weight,
                        hintText: widget.unit == WeightUnit.lbs
                            ? formatNumber(225, locale: l10n.localeName)
                            : formatNumber(
                                112.5,
                                locale: l10n.localeName,
                                decimals: 1,
                              ),
                        suffixText: widget.unit.displayName,
                      ),
                      style: inputStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _repsFocus.requestFocus(),
                      autofocus: !_isEditing,
                      validator: _validateWeight,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      focusNode: _repsFocus,
                      decoration: InputDecoration(
                        labelText: l10n.repsLabel,
                        hintText: '5',
                      ),
                      style: inputStyle,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      validator: _validateReps,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _DateField(
                label: formatRelativeDate(_date, widget.clock(), l10n),
                date: _date,
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.xl),
              _EstimatePanel(estimate: estimate, unit: widget.unit),
              if (highReps) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  key: const Key('high-reps-warning'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.highRepsWarning(accurateRepsLimit),
                        style: text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ElevatedButton(
            key: const Key('save-entry-button'),
            onPressed: _save,
            child: Text(_isEditing ? l10n.saveChanges : l10n.save),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppRadii.sm);
    return Semantics(
      button: true,
      label: l10n.dateSemantics(label, localizations.formatMediumDate(date)),
      onTapHint: l10n.changeDateHint,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          key: const Key('entry-date-field'),
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTapTarget + 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      // Wraps the date under the label when both don't fit.
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(label, style: text.titleMedium),
                          Text(
                            localizations.formatMediumDate(date),
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
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

class _EstimatePanel extends StatelessWidget {
  const _EstimatePanel({required this.estimate, required this.unit});

  final double? estimate;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.estimatedOneRm,
      value: estimate == null
          ? l10n.estimateEmptySemantics
          : formatWeight(estimate!, unit, locale: l10n.localeName),
      excludeSemantics: true,
      child: KnurlPanel(
        key: const Key('estimate-panel'),
        borderColor: estimate == null ? AppColors.outline : AppColors.accent,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.estimatedOneRm, style: text.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  estimate == null
                      ? '—'
                      : formatWeight(estimate!, unit, locale: l10n.localeName),
                  key: const Key('estimate-value'),
                  style: text.displayLarge?.copyWith(
                    fontSize: 56,
                    color: estimate == null
                        ? AppColors.textMuted
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
