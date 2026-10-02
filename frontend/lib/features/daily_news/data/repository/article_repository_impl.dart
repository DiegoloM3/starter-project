import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService,this._appDatabase);
  
  /// Any exception of the request (a [NewsApiService] failure) becomes a [DataFailed]. It is caught as an
  /// [Exception] so this layer does not import the HTTP client (docs/ARCHITECTURE_VIOLATIONS.md, 1.2.4).
  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final articles = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() async {
    try {
      final records = await _appDatabase.articleDAO.getArticles();
      return DataSuccess(records.map((record) => record.toModel().toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  /// Removed by its URL, so it also works for an article that comes from NewsAPI (without a local ID).
  @override
  Future<void> removeArticle(ArticleEntity article) {
    final url = article.url;
    if (url == null) return _appDatabase.articleDAO.deleteArticle(_toRecord(article));
    return _appDatabase.articleDAO.deleteArticleByUrl(url);
  }

  /// An article that is already saved is not saved again.
  @override
  Future<void> saveArticle(ArticleEntity article) async {
    final url = article.url;
    if (url != null && await _appDatabase.articleDAO.findArticleByUrl(url) != null) return;
    await _appDatabase.articleDAO.insertArticle(_toRecord(article));
  }

  @override
  Future<DataState<bool>> isArticleSaved(ArticleEntity article) async {
    try {
      final savedArticle = await _appDatabase.articleDAO.findArticleByUrl(article.url ?? '');
      return DataSuccess(savedArticle != null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  SavedArticleRecord _toRecord(ArticleEntity article) => SavedArticleRecord.fromModel(ArticleModel.fromEntity(article));
}
