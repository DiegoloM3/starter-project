import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleLocalDataSource {
  Future<List<ArticleEntity>> getSavedArticles();
  Future<void> saveArticle(ArticleEntity article);
  Future<void> removeArticle(ArticleEntity article);
}
