import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_names.dart';
import '../models/exercise.dart';
import '../repositories/exercise_library.dart';
import '../repositories/records_repository.dart';
import 'save_error.dart';
import 'undo_snack_bar.dart';
import 'theme/app_theme.dart';

/// Show/hide exercises on Home; create, rename and delete custom ones.
class ManageExercisesScreen extends StatefulWidget {
  const ManageExercisesScreen({
    super.key,
    required this.library,
    required this.records,
  });

  final ExerciseLibrary library;
  final RecordsRepository records;

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
    final result = await showDialog<_DialogResult>(
      context: context,
      builder: (_) => _ExerciseDialog(library: library),
    );
    if (result is _Save) await library.addCustom(result.name);
  }

  Future<void> _editExercise(ExerciseTemplate exercise) async {
    final result = await showDialog<_DialogResult>(
      context: context,
      builder: (_) => _ExerciseDialog(library: library, editing: exercise),
    );
    switch (result) {
      case _Save(:final name) when name != exercise.name:
        await library.renameCustom(exercise.id, name);
      case _Delete():
        await _deleteExercise(exercise);
      case _Save() || null:
        break;
    }
  }

  /// Deletes a custom exercise and its records, with Undo.
  Future<void> _deleteExercise(ExerciseTemplate exercise) async {
    final l10n = AppLocalizations.of(context);
    final removed = await library.removeCustom(exercise.id);
    final List<ExerciseRecord> records;
    try {
      records = await widget.records.deleteAll(exercise.id);
    } on Exception {
      if (mounted) showSaveError(context);
      return;
    }
    if (!mounted) return;
    showUndoSnackBar(
      context,
      message: l10n.deletedExercise(exercise.name, records.length),
      onUndo: () async {
        await library.restoreCustom(removed);
        await widget.records.restoreAll(exercise.id, records);
      },
    );
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
                _ExerciseGroup(
                  library: library,
                  exercises: group,
                  onEdit: _editExercise,
                ),
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
  const _ExerciseGroup({
    required this.library,
    required this.exercises,
    required this.onEdit,
  });

  final ExerciseLibrary library;
  final List<ExerciseTemplate> exercises;
  final ValueChanged<ExerciseTemplate> onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
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
              child: Row(
                children: [
                  Expanded(child: _toggle(context, text, exercise)),
                  if (library.isCustom(exercise.id))
                    IconButton(
                      key: Key('edit-${exercise.id}'),
                      tooltip: l10n.editExercise,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.textSecondary,
                      onPressed: () => onEdit(exercise),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _toggle(
    BuildContext context,
    TextTheme text,
    ExerciseTemplate exercise,
  ) => SwitchListTile(
    key: Key('toggle-${exercise.id}'),
    value: !library.isHidden(exercise.id),
    onChanged: (show) => library.setHidden(exercise.id, hidden: !show),
    activeThumbColor: AppColors.onAccent,
    activeTrackColor: AppColors.accent,
    secondary: SvgPicture.asset(
      exercise.assetPath,
      excludeFromSemantics: true,
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(
        library.isHidden(exercise.id) ? AppColors.textMuted : AppColors.accent,
        BlendMode.srcIn,
      ),
    ),
    title: Text(
      AppLocalizations.of(context).exerciseName(exercise),
      style: text.titleMedium,
    ),
  );
}

/// What the exercise dialog was closed with.
sealed class _DialogResult {}

class _Save extends _DialogResult {
  _Save(this.name);

  final String name;
}

class _Delete extends _DialogResult {}

/// Name dialog to create a custom exercise, or to rename or delete
/// [editing].
class _ExerciseDialog extends StatefulWidget {
  const _ExerciseDialog({required this.library, this.editing});

  final ExerciseLibrary library;
  final ExerciseTemplate? editing;

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  late final _controller = TextEditingController(text: widget.editing?.name);
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final editingId = widget.editing?.id;
    final error = widget.library.validateName(
      _controller.text,
      localizedNames: [
        for (final e in widget.library.all)
          if (e.id != editingId) l10n.exerciseName(e),
      ],
      renaming: editingId,
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
    Navigator.of(context).pop(_Save(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return AlertDialog(
      // Large text on a small phone can stack the actions; scroll, don't clip.
      scrollable: true,
      title: Text(_isEditing ? l10n.editExercise : l10n.newExercise),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: Key(_isEditing ? 'edit-exercise-name' : 'new-exercise-name'),
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
          if (_isEditing)
            TextButton.icon(
              key: const Key('delete-exercise-button'),
              onPressed: () => Navigator.of(context).pop(_Delete()),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(material.deleteButtonTooltip),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(material.cancelButtonLabel),
        ),
        TextButton(
          key: Key(
            _isEditing ? 'save-exercise-button' : 'create-exercise-button',
          ),
          onPressed: _submit,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: Text(_isEditing ? l10n.save : l10n.create),
        ),
      ],
    );
  }
}
