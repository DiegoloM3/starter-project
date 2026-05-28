import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/article.dart';
import 'article_tile.dart';

class UserArticleTile extends StatelessWidget {
  final ArticleEntity article;
  final void Function(ArticleEntity) onArticlePressed;
  final void Function(ArticleEntity) onEdit;
  final void Function(ArticleEntity) onDelete;

  const UserArticleTile({
    Key? key,
    required this.article,
    required this.onArticlePressed,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        ArticleWidget(
          article: article,
          showStatus: true,
          showReadingTime: true,
          onArticlePressed: onArticlePressed,
        ),
        Positioned(
          top: 8,
          right: 4,
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') onEdit(article);
              if (value == 'delete') onDelete(article);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
