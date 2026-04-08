import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'article_local_datasource.dart';

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  final ArticleDao _articleDao;

  ArticleLocalDataSourceImpl(this._articleDao);

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _articleDao.getArticles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _articleDao.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _articleDao.deleteArticle(ArticleModel.fromEntity(article));
  }
}
