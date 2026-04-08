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

  /// Deletes a community article. If [imageUrl] is non-null, the underlying
  /// Storage object is deleted on a best-effort basis (failures are swallowed
  /// so a missing or already-deleted file does not block the doc deletion).
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  });

  /// Updates `title`, `description`, `content`, and `imageUrl` for an existing
  /// article. `publishedAt` and `uid` are NOT touched. If [oldImageUrl] is
  /// different from [imageUrl] and non-null, the previous Storage object is
  /// deleted on a best-effort basis.
  Future<void> updateArticle({
    required String firestoreId,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? oldImageUrl,
  });
}
