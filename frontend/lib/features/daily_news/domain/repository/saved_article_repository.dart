import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Articles the reader bookmarked on this device.
abstract interface class SavedArticleRepository {
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  Future<DataState<void>> saveArticle(ArticleEntity article);

  Future<DataState<void>> removeArticle(String id);

}
