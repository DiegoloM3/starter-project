import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';

/// Hand written test double for [JournalistArticleRepository].
///
/// It records what the use cases asked for and returns whatever the test
/// configured, which is everything needed to assert business rules without
/// pulling a mocking framework into the project.
class FakeJournalistArticleRepository implements JournalistArticleRepository {
  DataState<List<JournalistArticleEntity>> userArticlesResult =
      const DataSuccess(<JournalistArticleEntity>[]);
  DataState<JournalistArticleEntity>? articleByIdResult;
  DataState<JournalistArticleEntity>? createResult;
  DataState<JournalistArticleEntity>? updateResult;
  DataState<void> deleteResult = const DataSuccess(null);
  DataState<List<JournalistArticleEntity>> publishedArticlesResult =
      const DataSuccess(<JournalistArticleEntity>[]);
  DataState<void> incrementViewCountResult = const DataSuccess(null);
  DataState<int>? updateAuthorNameResult;

  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int incrementViewCountCallCount = 0;
  int updateAuthorNameCallCount = 0;

  JournalistArticleEntity? lastCreatedArticle;
  JournalistArticleEntity? lastUpdatedArticle;
  String? lastRequestedArticleId;
  String? lastDeletedArticleId;
  String? lastViewedArticleId;
  String? lastUserId;
  ArticleStatus? lastStatusFilter;
  String? lastSearchQuery;
  int? lastPublishedArticlesLimit;
  String? lastPublishedArticlesAuthorId;
  String? lastPublishedArticlesExcludeArticleId;
  String? lastPublishedArticlesStartAfterArticleId;
  DateTime? lastPublishedAfter;
  String? lastRenamedUserId;
  String? lastAuthorName;

  @override
  Future<DataState<List<JournalistArticleEntity>>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  }) async {
    lastUserId = userId;
    lastStatusFilter = status;
    lastSearchQuery = searchQuery;
    return userArticlesResult;
  }

  @override
  Future<DataState<JournalistArticleEntity>> getArticleById(
    String articleId,
  ) async {
    lastRequestedArticleId = articleId;
    return articleByIdResult ??
        const DataSuccess(JournalistArticleEntity(id: 'unset'));
  }

  /// Mirrors `JournalistArticleRepositoryImpl`, which stamps the timestamps
  /// the backend owns before storing and hands the stored article back. A
  /// fake that skipped them would let a screen that reads `updatedAt` pass
  /// its tests and fail in the app.
  @override
  Future<DataState<JournalistArticleEntity>> createArticle(
    JournalistArticleEntity article,
  ) async {
    createCallCount++;
    lastCreatedArticle = article;

    final now = DateTime.now();

    return createResult ??
        DataSuccess(article.copyWith(
          id: 'created-id',
          createdAt: article.createdAt ?? now,
          updatedAt: now,
        ));
  }

  @override
  Future<DataState<JournalistArticleEntity>> updateArticle(
    JournalistArticleEntity article,
  ) async {
    updateCallCount++;
    lastUpdatedArticle = article;

    return updateResult ??
        DataSuccess(article.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    deleteCallCount++;
    lastDeletedArticleId = articleId;
    return deleteResult;
  }

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) async {
    lastPublishedArticlesLimit = limit;
    lastPublishedArticlesAuthorId = authorId;
    lastPublishedArticlesExcludeArticleId = excludeArticleId;
    lastPublishedArticlesStartAfterArticleId = startAfterArticleId;
    lastPublishedAfter = publishedAfter;
    return publishedArticlesResult;
  }

  @override
  Future<DataState<int>> updateAuthorName({
    required String userId,
    required String authorName,
  }) async {
    updateAuthorNameCallCount++;
    lastRenamedUserId = userId;
    lastAuthorName = authorName;

    return updateAuthorNameResult ?? const DataSuccess(0);
  }

  @override
  Future<DataState<void>> incrementViewCount(String articleId) async {
    incrementViewCountCallCount++;
    lastViewedArticleId = articleId;
    return incrementViewCountResult;
  }
}
