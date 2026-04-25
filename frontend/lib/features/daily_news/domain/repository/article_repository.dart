import '../../../../core/resources/data_state.dart';
import '../../data/models/news_response.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<NewsResponse>> getNewsArticles();

  // Database methods
  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);
}
