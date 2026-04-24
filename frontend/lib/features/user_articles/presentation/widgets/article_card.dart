import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final UserArticleEntity article;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final dateFormat = DateFormat.yMMMd();
    final hasValidThumbnail = article.thumbnailURL.startsWith('http');

    return Semantics(
      label: 'Article ${article.title}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: theme.radii.mdRadius,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: theme.radii.mdRadius,
            border: Border.all(color: theme.divider),
          ),
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: theme.radii.smRadius,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: hasValidThumbnail
                        ? CachedNetworkImage(
                            imageUrl: article.thumbnailURL,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: theme.surfaceMuted,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: theme.surfaceMuted,
                              child: Icon(
                                Icons.image_not_supported,
                                color: theme.onSurfaceMuted,
                              ),
                            ),
                          )
                        : Container(
                            color: theme.surfaceMuted,
                            child: Icon(
                              Icons.article,
                              color: theme.onSurfaceMuted,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: theme.onSurface,
                              ),
                            ),
                          ),
                          _StatusPill(status: article.status),
                        ],
                      ),
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.onSurfaceMuted,
                        ),
                      ),
                      SizedBox(height: theme.spacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateFormat.format(article.updatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.onSurfaceMuted,
                              ),
                            ),
                          ),
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Edit',
                              color: theme.onSurfaceMuted,
                              visualDensity: VisualDensity.compact,
                            ),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                              ),
                              tooltip: 'Delete',
                              color: theme.danger,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final UserArticleStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isPublished = status == UserArticleStatus.published;
    final bg = isPublished ? theme.accent : theme.surfaceMuted;
    final fg = isPublished ? theme.onPrimary : theme.onSurfaceMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(theme.radii.pill),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
