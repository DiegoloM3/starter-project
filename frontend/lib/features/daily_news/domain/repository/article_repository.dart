import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  Future<void> publishArticle(ArticleEntity article);

  // Database methods
  Future < List < ArticleEntity >> getSavedArticles();

  Future < void > saveArticle(ArticleEntity article);

  Future < void > removeArticle(ArticleEntity article);
}