import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../utils/formulas.dart';
import 'theme/app_theme.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.exerciseName,
    required this.assetPath,
    required this.unit,
  });

  final String exerciseName;
  final String assetPath;
  final WeightUnit unit;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final displayWeight = parseWeight(_weightController.text);
    final weightInKg = widget.unit == WeightUnit.lbs
        ? lbsToKg(displayWeight)
        : displayWeight;
    final reps = int.parse(_repsController.text);
    final oneRM = calculateOneRM(weightInKg, reps);

    final record = ExerciseRecord(
      weight: weightInKg,
      reps: reps,
      oneRM: oneRM,
      date: DateTime.now(),
    );

    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontSize: 22);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              widget.assetPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(widget.exerciseName),
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
                'Enter your lift',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        hintText: widget.unit == WeightUnit.lbs
                            ? '225'
                            : '112.5',
                        prefixIcon: const Icon(Icons.monitor_weight_rounded),
                        suffixText: widget.unit.displayName,
                      ),
                      style: inputStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final v = tryParseWeight(value);
                        if (v == null || v <= 0) return 'Invalid';
                        if (v > widget.unit.maxWeight) {
                          return 'Max ${widget.unit.maxWeight.toStringAsFixed(0)} ${widget.unit.displayName}';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        hintText: '5',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                      style: inputStyle,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final v = int.tryParse(value);
                        if (v == null || v <= 0) return 'Invalid';
                        if (v > maxReps) return 'Max $maxReps reps';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Calculate 1RM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
