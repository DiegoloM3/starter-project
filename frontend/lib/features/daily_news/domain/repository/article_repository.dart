import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // News API
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Local database
  Future<List<ArticleEntity>> getSavedArticles();
  Future<void> saveArticle(ArticleEntity article);
  Future<void> removeArticle(ArticleEntity article);

  // Firestore CRUD
  Future<DataState<ArticleEntity>> createArticle(ArticleEntity article);
  Future<DataState<ArticleEntity>> updateArticle(ArticleEntity article);
  Future<DataState<void>> deleteArticle(String articleId);

  // Merged feed (News API + Firestore published)
  Stream<DataState<List<ArticleEntity>>> getFeedArticles();

  // Firestore real-time queries
  Stream<DataState<List<ArticleEntity>>> getPublishedArticles();
  Stream<DataState<List<ArticleEntity>>> getUserArticles(String userId);
  Stream<DataState<List<ArticleEntity>>> getDraftArticles(String userId);

  // Search
  Stream<DataState<List<ArticleEntity>>> searchArticles(String query);

  // Storage
  Future<DataState<String>> uploadThumbnail({
    required String articleId,
    required String filePath,
  });
}