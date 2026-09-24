import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Compact single-choice control: one chip per value, the selected one
/// filled with the accent. Each chip is a 48 dp tap target.
class SegmentedChips<T extends Enum> extends StatelessWidget {
  const SegmentedChips({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.semanticLabelOf,
    this.keyPrefix = 'chip',
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;

  /// What screen readers say for a chip whose label is an abbreviation
  /// ("3M", "%"); the visible label when null.
  final String Function(T value)? semanticLabelOf;
  final ValueChanged<T> onSelected;

  /// Chips get `Key('$keyPrefix-${value.name}')` for tests: the same in
  /// every language.
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in values)
          _Chip(
            key: Key('$keyPrefix-${value.name}'),
            label: labelOf(value),
            semanticLabel: semanticLabelOf?.call(value),
            selected: value == selected,
            onTap: () => onSelected(value),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: selected ? AppColors.onAccent : AppColors.textSecondary,
      letterSpacing: 0.8,
    );
    return Semantics(
      selected: selected,
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinTapTarget,
            minHeight: kMinTapTarget,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(label, style: style),
            ),
          ),
        ),
      ),
    );
  }
}
