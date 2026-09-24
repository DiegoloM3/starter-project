import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_remote_data_source.dart';

/// The News API and the saved-articles table, behind one contract.
///
/// It names neither: the headlines come from [NewsRemoteDataSource] and the
/// saved ones from [AppDatabase], and both report trouble by throwing, which
/// [_guard] turns into a [DataState] so no caller is ever left waiting.
class ArticleRepositoryImpl implements ArticleRepository {
  final NewsRemoteDataSource _remoteDataSource;
  final AppDatabase _appDatabase;

  const ArticleRepositoryImpl(this._remoteDataSource, this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles({
    NewsCategory category = NewsCategory.general,
  }) {
    return _guard(() async {
      final articles = await _remoteDataSource.getNewsArticles(category);

      return _toEntities(articles);
    });
  }

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() {
    return _guard(() async {
      final articles = await _appDatabase.articleDAO.getArticles();

      return _toEntities(articles);
    });
  }

  /// Stores [article] unless it is already saved.
  ///
  /// The guard lives here because it is about the database not growing a
  /// second row for the same article: the id is generated on insert, so
  /// nothing else stops the same article being saved twice.
  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) {
    return _guard(() async {
      final saved = await _appDatabase.articleDAO.getArticles();

      if (saved.any(article.isSameArticleAs)) {
        return;
      }

      await _appDatabase.articleDAO.insertArticle(
        ArticleModel.fromEntity(article),
      );
    });
  }

  /// Removes the stored copy of [article].
  ///
  /// It deletes the article it finds rather than the one it is handed: Floor
  /// deletes by primary key, and an article coming from the news API has no
  /// id — only the copy already in the database does. Passing the API copy
  /// straight through deleted nothing at all.
  @override
  Future<DataState<void>> removeArticle(ArticleEntity article) {
    return _guard(() async {
      final saved = await _appDatabase.articleDAO.getArticles();
      final stored = saved.where(article.isSameArticleAs);

      for (final storedArticle in stored) {
        await _appDatabase.articleDAO.deleteArticle(storedArticle);
      }
    });
  }

  /// Runs [operation] and guarantees a [DataState] comes back.
  ///
  /// The broad `catch` is deliberate, and matches the other repositories: an
  /// error that escapes does not surface as a failure, it leaves the caller's
  /// `await` hanging and the screen spinning. That applies to the local
  /// database as much as to the network — a disk error is no less real for
  /// being rarer.
  Future<DataState<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return DataSuccess(await operation());
    } on RemoteException catch (error) {
      return DataFailed(error);
    } catch (error) {
      return DataFailed(error);
    }
  }

  List<ArticleEntity> _toEntities(List<ArticleModel> articles) {
    return articles.map((article) => article.toEntity()).toList();
  }
}
