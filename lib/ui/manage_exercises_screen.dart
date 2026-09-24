import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_names.dart';
import '../repositories/exercise_library.dart';
import 'theme/app_theme.dart';

/// Show/hide exercises on Home and create custom ones.
class ManageExercisesScreen extends StatefulWidget {
  const ManageExercisesScreen({super.key, required this.library});

  final ExerciseLibrary library;

  @override
  State<ManageExercisesScreen> createState() => _ManageExercisesScreenState();
}

class _ManageExercisesScreenState extends State<ManageExercisesScreen> {
  final _search = TextEditingController();

  ExerciseLibrary get library => widget.library;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exercises)),
      body: ListenableBuilder(
        listenable: library,
        builder: (context, _) {
          final query = _search.text.trim().toLowerCase();
          // English names match too: lifters often know a lift by both.
          final matches = library.all
              .where(
                (e) =>
                    l10n.exerciseName(e).toLowerCase().contains(query) ||
                    e.name.toLowerCase().contains(query),
              )
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              TextField(
                key: const Key('exercise-search'),
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchExercises,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _search.clear,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.shownOnHome(library.visible.length, library.all.length),
                key: const Key('shown-count'),
                style: text.bodySmall,
              ),
              if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Text(
                    l10n.noExercisesMatch(_search.text.trim()),
                    textAlign: TextAlign.center,
                    style: text.bodyLarge,
                  ),
                ),
              for (final (category, group) in groupByCategory(matches)) ...[
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.categoryName(category).toUpperCase(),
                    style: text.labelMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ExerciseGroup(library: library, exercises: group),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(l10n.hiddenKeepRecords, style: text.bodySmall),
            ],
          );
        },
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
          onPressed: _addExercise,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.newExercise),
        ),
      ),
    );
  }
}

class _ExerciseGroup extends StatelessWidget {
  const _ExerciseGroup({required this.library, required this.exercises});

  final ExerciseLibrary library;
  final List<ExerciseTemplate> exercises;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (final (index, exercise) in exercises.indexed)
            DecoratedBox(
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : const Border(top: BorderSide(color: AppColors.outline)),
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
                  colorFilter: ColorFilter.mode(
                    library.isHidden(exercise.id)
                        ? AppColors.textMuted
                        : AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context).exerciseName(exercise),
                  style: text.titleMedium,
                ),
              ),
            ),
        ],
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
    final l10n = AppLocalizations.of(context);
    final error = widget.library.validateName(
      _controller.text,
      localizedNames: widget.library.all.map(l10n.exerciseName),
    );
    if (error != null) {
      setState(
        () => _error = switch (error) {
          ExerciseNameError.empty => l10n.enterAName,
          ExerciseNameError.tooLong => l10n.maxCharacters(
            ExerciseLibrary.maxNameLength,
          ),
          ExerciseNameError.duplicate => l10n.exerciseExists,
        },
      );
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newExercise),
      content: TextField(
        key: const Key('new-exercise-name'),
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: ExerciseLibrary.maxNameLength,
        decoration: InputDecoration(
          labelText: l10n.nameLabel,
          hintText: l10n.nameHint,
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
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const Key('create-exercise-button'),
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: Text(l10n.create),
        ),
      ],
    );
  }
}
