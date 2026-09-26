import '../../models/article.dart';

/// Platform-neutral contract for the legacy bookmark store.
///
/// Concrete implementations remain Floor on native platforms and
/// SharedPreferences on web; repositories depend on this contract only.
abstract class ArticleLocalDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<void> saveArticle(ArticleModel article);
  Future<void> removeArticle(ArticleModel article);
}
