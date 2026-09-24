import 'dart:typed_data';

import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

/// A stored article that satisfies every publishing rule.
JournalistArticleEntity publishableArticle({
  String? id = 'article-1',
  ArticleStatus status = ArticleStatus.draft,
}) {
  return JournalistArticleEntity(
    id: id,
    title: 'The night bus driver who knows everyone',
    description: 'A ride along the last line of the night.',
    content: 'The depot doors open at 23:40 and the route begins.',
    author: 'Alex Rivera',
    userId: 'journalist-1',
    thumbnailUrl: 'https://storage/media/articles/journalist-1/bus.jpg',
    status: status,
  );
}

ArticleThumbnailEntity thumbnail({
  String fileName = 'cover.jpg',
  int sizeInBytes = 1024,
}) {
  return ArticleThumbnailEntity(
    fileName: fileName,
    bytes: Uint8List(sizeInBytes),
  );
}
