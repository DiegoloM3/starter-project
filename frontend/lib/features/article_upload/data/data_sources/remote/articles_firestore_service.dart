import 'package:news_app_clean_architecture/features/article_upload/data/models/journalist_article_model.dart';

abstract class ArticlesFirestoreService {
  /// Reserves a doc id without any I/O. Returns the allocated id.
  String allocateArticleId();

  Future<void> createArticle(JournalistArticleModel model);

  Future<void> updateArticle(String articleId, Map<String, dynamic> partial);

  Future<void> deleteArticle(String articleId);

  Stream<JournalistArticleModel?> watchArticleById(String articleId);

  Stream<List<JournalistArticleModel>> watchByAuthor(String userId);

  Stream<List<JournalistArticleModel>> watchCommunityFeed({int limit});

  /// Atomic batch: writes/removes both mirror docs and adjusts favoriteCount.
  Future<void> toggleFavorite({
    required String articleId,
    required String userId,
    required bool currentlyFavorited,
  });

  Stream<List<String>> watchFavoriteArticleIds(String userId);
}
