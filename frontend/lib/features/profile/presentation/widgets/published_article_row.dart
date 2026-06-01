import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class PublishedArticleRow extends StatelessWidget {
  final ArticleEntity article;
  final String categoryName;
  final VoidCallback onTapView;
  final VoidCallback onTapDelete;
  final VoidCallback onTapEdit;

  const PublishedArticleRow({
    super.key,
    required this.article,
    required this.categoryName,
    required this.onTapView,
    required this.onTapDelete,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapView,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            width: AppSpacing.thumbnailSm,
            height: AppSpacing.thumbnailSm,
            child: article.coverHorizontalUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.coverHorizontalUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => TortuSkeletonBox(
                      width: AppSpacing.thumbnailSm,
                      height: AppSpacing.thumbnailSm,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary,
                        size: AppSpacing.iconSizeMd,
                      ),
                    ),
                  )
                : Container(color: AppColors.surface),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TortuCategoryChip.fromName(categoryName),
              const SizedBox(height: AppSpacing.xs),
              Text(
                article.title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            switch (value) {
              case 'view':
                onTapView();
              case 'edit':
                onTapEdit();
              case 'delete':
                _confirmDelete(context);
            }
          },
          itemBuilder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            return [
              PopupMenuItem(value: 'view', child: Text(l10n.articleMenuView)),
              PopupMenuItem(value: 'edit', child: Text(l10n.articleMenuEdit)),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.articleMenuDelete,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ];
          },
        ),
      ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.articleDeleteTitle),
        content: Text(l10n.articleDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.articleDeleteCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onTapDelete();
            },
            child: Text(
              l10n.articleMenuDelete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
