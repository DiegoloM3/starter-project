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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.deleteArticle,
              style: AppTypography.serif(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.t1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Article preview card (if article provided)
          if (article != null) _buildArticlePreview(),
          // Warning text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.deleteArticleConfirmation,
              style: AppTypography.sans(
                fontSize: 13,
                color: AppColors.t2,
                height: 1.55,
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
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.deletePermanently,
                style: AppTypography.sans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                l10n.cancel,
                style: AppTypography.sans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.t2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: _buildPreviewThumbnail(),
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
                  style: AppTypography.serif(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.t1,
                  ),
                ),
                if (article?.status != null) ...[
                  const SizedBox(height: 4),
                  StatusBadge(status: article!.status!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewThumbnail() {
    final url = article?.thumbnailUrl;
    if (url == null || url.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        color: AppColors.ink.withValues(alpha: 0.08),
        child: const Icon(Icons.image_outlined, color: AppColors.t3, size: 16),
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
        color: AppColors.ink.withValues(alpha: 0.08),
      ),
    );
  }
}
