import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class LocalArticleRepository {
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  Future<DataState<bool>> saveArticle(ArticleEntity article);

  Future<DataState<bool>> removeArticle(ArticleEntity article);
}
