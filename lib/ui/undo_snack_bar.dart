import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Undo for a destructive action: [message] and an Undo button, replacing
/// any SnackBar on screen. Unlike [SnackBarAction], the button shrinks its
/// label instead of overflowing on a narrow phone with large text.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final undo = AppLocalizations.of(context).undo;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        persist: true,
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: TextButton(
                key: const Key('undo-button'),
                onPressed: () {
                  messenger.hideCurrentSnackBar(
                    reason: SnackBarClosedReason.action,
                  );
                  onUndo();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: FittedBox(fit: BoxFit.scaleDown, child: Text(undo)),
              ),
            ),
          ],
        ),
      ),
    );
}
