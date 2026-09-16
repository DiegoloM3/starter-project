import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/editorial_dialog.dart';

/// Plain-English confirmation before an article is deleted. Resolves to
/// `true` only when the user confirmed.
class DeleteArticleDialog extends StatelessWidget {
  final String title;

  const DeleteArticleDialog({super.key, required this.title});

  static const String body =
      'The article and its photo will be removed. Readers who saved it will lose it too.';

  static Future<bool> show(BuildContext context, {required String title}) async {
    final confirmed = await showEditorialDialog<bool>(
      context: context,
      builder: (_) => DeleteArticleDialog(title: title),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Delete "$title"?', style: AppTypography.dialogTitle.copyWith(color: palette.ink)),
            const SizedBox(height: AppSpacing.md),
            Text(body, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
            const SizedBox(height: AppSpacing.xxl),
            DestructiveButton(
              label: 'Delete article',
              filled: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(AppSizes.button)),
              child: const Text('Keep it'),
            ),
          ],
        ),
      ),
    );
  }
}
