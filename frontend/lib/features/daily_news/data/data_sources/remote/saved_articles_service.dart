import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class SavedArticlesService {
  Future<List<ArticleEntity>> getSavedArticles(String uid);
  Future<void> saveArticle(String uid, ArticleEntity article);
  Future<void> removeArticle(String uid, ArticleEntity article);
  Future<bool> isSaved(String uid, ArticleEntity article);
}
