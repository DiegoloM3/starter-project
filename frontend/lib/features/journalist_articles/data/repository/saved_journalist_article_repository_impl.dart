import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/saved_journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';

class SavedJournalistArticleRepositoryImpl implements SavedJournalistArticleRepository {
  final SavedJournalistArticleRemoteDataSource _savedArticleDataSource;
  final JournalistArticleRemoteDataSource _articleDataSource;

  SavedJournalistArticleRepositoryImpl(this._savedArticleDataSource, this._articleDataSource);

  /// The list only keeps the IDs of the saved articles, so the articles are read afterwards.
  @override
  Future<DataState<List<JournalistArticleEntity>>> getSavedArticles() async {
    try {
      final savedArticleIds = await _savedArticleDataSource.getSavedArticleIds();
      final articles = await _articleDataSource.getArticles(savedArticleIds);
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<bool>> isArticleSaved(String articleId) async {
    try {
      return DataSuccess(await _savedArticleDataSource.isArticleSaved(articleId));
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> saveArticle(String articleId) async {
    try {
      await _savedArticleDataSource.saveArticle(articleId);
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> removeSavedArticle(String articleId) async {
    try {
      await _savedArticleDataSource.removeSavedArticle(articleId);
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
