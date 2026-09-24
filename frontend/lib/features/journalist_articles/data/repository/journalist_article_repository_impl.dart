import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../domain/entities/article_failures.dart';
import '../../domain/entities/article_status.dart';
import '../../domain/entities/journalist_article.dart';
import '../../domain/repository/journalist_article_repository.dart';
import '../data_sources/remote/firestore_article_service.dart';
import '../models/journalist_article_model.dart';

/// Firestore implementation of [JournalistArticleRepository].
///
/// It is the only place that knows both sides: it turns entities into models
/// on the way down, and the data source's errors into the domain's own
/// failures on the way back up. It never names Firestore itself — the service
/// hands it a [RemoteException] carrying the provider's code (rule 1.2.4).
class JournalistArticleRepositoryImpl implements JournalistArticleRepository {
  final FirestoreArticleService _articleService;

  const JournalistArticleRepositoryImpl(this._articleService);

  @override
  Future<DataState<List<JournalistArticleEntity>>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  }) {
    return _guard(() async {
      final articles = await _articleService.getUserArticles(
        userId: userId,
        status: status,
        searchQuery: searchQuery,
      );

      return _toEntities(articles);
    });
  }

  @override
  Future<DataState<JournalistArticleEntity>> getArticleById(String articleId) {
    return _guard(
      () async {
        final article = await _articleService.getArticleById(articleId);

        if (article == null) {
          throw ArticleNotFoundException(articleId);
        }

        return article.toEntity();
      },
      articleId: articleId,
    );
  }

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) {
    return _guard(() async {
      final articles = await _articleService.getPublishedArticles(
        limit: limit,
        authorId: authorId,
        excludeArticleId: excludeArticleId,
        startAfterArticleId: startAfterArticleId,
        publishedAfter: publishedAfter,
      );

      return _toEntities(articles);
    });
  }

  @override
  Future<DataState<JournalistArticleEntity>> createArticle(
    JournalistArticleEntity article,
  ) {
    return _guard(() async {
      final now = DateTime.now();

      final created = await _articleService.createArticle(
        JournalistArticleModel.fromEntity(
          article.copyWith(
            createdAt: article.createdAt ?? now,
            updatedAt: now,
          ),
        ),
      );

      return created.toEntity();
    });
  }

  @override
  Future<DataState<JournalistArticleEntity>> updateArticle(
    JournalistArticleEntity article,
  ) {
    return _guard(
      () async {
        if (!article.isStored) {
          throw const ArticleNotStoredException();
        }

        final updated = await _articleService.updateArticle(
          JournalistArticleModel.fromEntity(
            article.copyWith(updatedAt: DateTime.now()),
          ),
        );

        return updated.toEntity();
      },
      articleId: article.id,
    );
  }

  @override
  Future<DataState<int>> updateAuthorName({
    required String userId,
    required String authorName,
  }) {
    return _guard(
      () => _articleService.updateAuthorName(
        userId: userId,
        authorName: authorName,
      ),
    );
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) {
    return _guard(
      () => _articleService.deleteArticle(articleId),
      articleId: articleId,
    );
  }

  @override
  Future<DataState<void>> incrementViewCount(String articleId) {
    return _guard(
      () => _articleService.incrementViewCount(articleId),
      articleId: articleId,
    );
  }

  /// Runs [operation] and guarantees a [DataState] comes back.
  ///
  /// The broad `catch` is deliberate: an error that escapes a repository does
  /// not show up as a failure, it leaves the caller's `await` hanging and the
  /// screen spinning. Every caller gets an answer, even for something we did
  /// not anticipate.
  ///
  /// [articleId] is given when the operation targets one document, so that the
  /// provider's `not-found` can be reported as the failure the domain already
  /// has a name for.
  Future<DataState<T>> _guard<T>(
    Future<T> Function() operation, {
    String? articleId,
  }) async {
    try {
      return DataSuccess(await operation());
    } on RemoteException catch (error) {
      return DataFailed(_toDomainFailure(error, articleId: articleId));
    } catch (error) {
      return DataFailed(error);
    }
  }

  /// Maps the provider's error code onto the failure the domain understands.
  Object _toDomainFailure(RemoteException error, {String? articleId}) {
    if (articleId != null && error.code == _notFoundCode) {
      return ArticleNotFoundException(articleId);
    }
    // Told apart from every other failure because it is the one the
    // journalist can act on: publishing in airplane mode used to report
    // "something went wrong", which says nothing about what to try next.
    if (_connectivityCodes.contains(error.code)) {
      return const NetworkUnavailableException();
    }

    return error;
  }

  /// The provider's code for a document that is not there.
  static const String _notFoundCode = 'not-found';

  /// What Firestore and Cloud Storage call "I could not reach the server".
  static const Set<String> _connectivityCodes = {
    RemoteException.unavailableCode,
    'deadline-exceeded',
    'network-request-failed',
  };

  List<JournalistArticleEntity> _toEntities(
    List<JournalistArticleModel> articles,
  ) {
    return articles.map((article) => article.toEntity()).toList();
  }
}
