import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repositories/exercise_library.dart';
import 'theme/app_theme.dart';

/// Show/hide exercises on Home and create custom ones.
class ManageExercisesScreen extends StatelessWidget {
  const ManageExercisesScreen({super.key, required this.library});

  final ExerciseLibrary library;

  Future<void> _addExercise(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NewExerciseDialog(library: library),
    );
    if (name == null) return;
    await library.addCustom(name);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: ListenableBuilder(
        listenable: library,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text('SHOW ON HOME', style: text.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: AppColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                side: const BorderSide(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  for (final (index, exercise) in library.all.indexed)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: index == 0
                            ? null
                            : const Border(
                                top: BorderSide(color: AppColors.outline),
                              ),
                      ),
                      child: SwitchListTile(
                        key: Key('toggle-${exercise.id}'),
                        value: !library.isHidden(exercise.id),
                        onChanged: (show) =>
                            library.setHidden(exercise.id, hidden: !show),
                        activeThumbColor: AppColors.onAccent,
                        activeTrackColor: AppColors.accent,
                        secondary: SvgPicture.asset(
                          exercise.assetPath,
                          width: 32,
                          height: 32,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(exercise.name, style: text.titleMedium),
                        subtitle: library.isCustom(exercise.id)
                            ? Text('Custom', style: text.bodySmall)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hidden exercises keep all their records.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: ElevatedButton.icon(
          key: const Key('new-exercise-button'),
          onPressed: () => _addExercise(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New exercise'),
        ),
      ),
    );
  }
}

class _NewExerciseDialog extends StatefulWidget {
  const _NewExerciseDialog({required this.library});

  final ExerciseLibrary library;

  @override
  State<_NewExerciseDialog> createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<_NewExerciseDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.library.validateName(_controller.text);
    if (error != null) {
      setState(
        () => _error = switch (error) {
          ExerciseNameError.empty => 'Enter a name',
          ExerciseNameError.tooLong =>
            'Max ${ExerciseLibrary.maxNameLength} characters',
          ExerciseNameError.duplicate => 'That exercise already exists',
        },
      );
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New exercise'),
      content: TextField(
        key: const Key('new-exercise-name'),
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: ExerciseLibrary.maxNameLength,
        decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'Zercher Squat',
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('create-exercise-button'),
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
