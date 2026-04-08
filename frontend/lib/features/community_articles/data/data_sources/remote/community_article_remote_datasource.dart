import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class CommunityArticleRemoteDataSource {
  Stream<List<ArticleEntity>> watchArticles();

  /// Uploads [imageFile] to Storage at `articles/{uid}/{timestamp}_{filename}`
  /// and returns the download URL.
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  });

  Future<String> publishArticle(ArticleEntity article);
}
