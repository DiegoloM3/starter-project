import 'package:flutter/material.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_article_list_card.dart';

// Thin wrapper that preserves the existing API for explore screens.
// The shared implementation lives in shared/widgets/tortutip_article_list_card.dart.
class ArticleListCard extends StatelessWidget {
  final ArticleEntity article;
  final CategoryEntity category;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final String? authorName;
  final String? authorAvatarUrl;

  const ArticleListCard({
    super.key,
    required this.article,
    required this.category,
    required this.isSaved,
    required this.onTap,
    required this.onBookmarkTap,
    this.authorName,
    this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return TortuArticleListCard(
      article: article,
      category: category,
      isSaved: isSaved,
      onTap: onTap,
      onBookmarkTap: onBookmarkTap,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
    );
  }
}
