import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class CommunityArticleRepository {
  /// Streams the most recent community articles, newest first.
  Stream<List<ArticleEntity>> watchArticles();

  /// Uploads an image to Storage and returns the download URL.
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  });

  /// Publishes a new article and returns the Firestore document ID.
  Future<String> publishArticle(ArticleEntity article);
}
