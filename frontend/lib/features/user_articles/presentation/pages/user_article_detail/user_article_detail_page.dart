import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

class UserArticleDetailPage extends StatelessWidget {
  const UserArticleDetailPage({required this.article, super.key});

  final UserArticleEntity article;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: article.thumbnailURL.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: article.thumbnailURL,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: theme.surfaceMuted,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: theme.onSurfaceMuted,
                        ),
                      ),
                    ),
                  )
                : ColoredBox(color: theme.surfaceMuted),
          ),
          Padding(
            padding: EdgeInsets.all(theme.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.onSurface,
                  ),
                ),
                SizedBox(height: theme.spacing.sm),
                Row(
                  children: [
                    Text(
                      'By ${article.authorName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.onSurfaceMuted,
                      ),
                    ),
                    const Text(' · '),
                    Text(
                      dateFormat.format(article.updatedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing.lg),
                if (article.description.isNotEmpty) ...[
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: theme.onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: theme.spacing.lg),
                ],
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: theme.onSurface,
                  ),
                ),
                if (article.tags.isNotEmpty) ...[
                  SizedBox(height: theme.spacing.lg),
                  Wrap(
                    spacing: theme.spacing.sm,
                    runSpacing: theme.spacing.sm,
                    children: article.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: theme.surfaceMuted,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
