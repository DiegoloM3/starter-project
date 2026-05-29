import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/article.dart';
import 'status_badge.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final ArticleEntity? article;

  const DeleteConfirmationDialog({Key? key, this.article}) : super(key: key);

  /// Shows the delete confirmation as a bottom sheet.
  /// Returns `true` if the user confirmed deletion.
  static Future<bool> show(BuildContext context, {ArticleEntity? article}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DeleteConfirmationDialog(article: article),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              color: cs.outline,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.deleteArticle,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: null,
                letterSpacing: null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Article preview card (if article provided)
          if (article != null) _buildArticlePreview(context),
          // Warning text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.deleteArticleConfirmation,
              style: tt.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w400,
                height: 1.55,
                letterSpacing: null,
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Delete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.deletePermanently,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: null,
                  letterSpacing: null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                l10n.cancel,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                  height: null,
                  letterSpacing: null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlePreview(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: _buildPreviewThumbnail(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyLarge?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: null,
                    letterSpacing: null,
                  ),
                ),
                if (article?.status != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  StatusBadge(status: article!.status!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewThumbnail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = article?.thumbnailUrl;
    if (url == null || url.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        color: cs.onSurface.withValues(alpha: 0.08),
        child: Icon(Icons.image_outlined, color: cs.outlineVariant, size: 16),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(
        width: 40,
        height: 40,
        color: cs.onSurface.withValues(alpha: 0.08),
      ),
    );
  }
}
