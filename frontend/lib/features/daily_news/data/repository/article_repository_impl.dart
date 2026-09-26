import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsArticlesDataSource _newsDataSource;
  final ArticleLocalDataSource _localDataSource;

  ArticleRepositoryImpl(this._newsDataSource, this._localDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final models = await _newsDataSource.getNewsArticles();
      return DataSuccess<List<ArticleEntity>>(
        models.map((model) => model.toEntity()).toList(growable: false),
      );
    } on NewsApiException catch (error) {
      return DataFailed(AppFailure(error.message, cause: error.cause));
    } catch (error) {
      return DataFailed(AppFailure('Unable to load daily news.', cause: error));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() => _localDataSource.getArticles();

  @override
  Future<void> removeArticle(ArticleEntity article) =>
      _localDataSource.removeArticle(ArticleModel.fromEntity(article));

  @override
  Future<void> saveArticle(ArticleEntity article) =>
      _localDataSource.saveArticle(ArticleModel.fromEntity(article));
}
