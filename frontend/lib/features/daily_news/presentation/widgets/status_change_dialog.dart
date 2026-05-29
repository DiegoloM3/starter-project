import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';

class StatusChangeDialog {
  static Future<bool> showPublishConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await _showDialog(
          context,
          title: l10n.publishConfirmTitle,
          message: l10n.publishConfirmMessage,
          confirmLabel: l10n.publish,
          confirmColor: Theme.of(context).colorScheme.primary,
        ) ??
        false;
  }

  static Future<bool> showArchiveConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await _showDialog(
          context,
          title: l10n.archiveConfirmTitle,
          message: l10n.archiveConfirmMessage,
          confirmLabel: l10n.archiveAction,
          confirmColor: context.semantic.warning,
        ) ??
        false;
  }

  static Future<bool?> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        return AlertDialog(
          title: Text(
            title,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: tt.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
              height: 1.55,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.cancel,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                confirmLabel,
                style: tt.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
