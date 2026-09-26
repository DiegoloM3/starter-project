import 'app_database.dart';
import '../../models/article.dart';
import 'article_local_data_source.dart';

class LegacyArticleLocalDataSource implements ArticleLocalDataSource {
  final AppDatabase _database;
  const LegacyArticleLocalDataSource(this._database);

  @override
  Future<List<ArticleModel>> getArticles() =>
      _database.articleDAO.getArticles();

  @override
  Future<void> saveArticle(ArticleModel article) =>
      _database.articleDAO.insertArticle(article);

  @override
  Future<void> removeArticle(ArticleModel article) =>
      _database.articleDAO.deleteArticle(article);
}

Future<LegacyArticleLocalDataSource>
    createLegacyArticleLocalDataSource() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  return LegacyArticleLocalDataSource(database);
}
