import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiDataSource _remote;
  final AppDatabase? _appDatabase;

  ArticleRepositoryImpl(this._remote, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final models = await _remote.getTopHeadlines();
      return DataSuccess(models.map((m) => m.toEntity()).toList());
    } on ArticleException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final models = await _requireDb().articleDAO.getArticles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _requireDb()
        .articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _requireDb()
        .articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }

  AppDatabase _requireDb() {
    final db = _appDatabase;
    if (db == null) {
      throw UnsupportedError(
          'Local article storage is not available on this platform.');
    }
    return db;
  }
}
