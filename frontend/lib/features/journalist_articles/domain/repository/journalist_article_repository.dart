import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_status.dart';
import '../entities/journalist_article.dart';

/// Contract for storing and retrieving the articles written by journalists.
///
/// The business layer only knows this abstraction: whether the articles live in
/// Firestore, in a local cache or in memory is decided by the data layer.
abstract class JournalistArticleRepository {
  /// Articles authored by [userId], newest first.
  ///
  /// [status] and [searchQuery] are optional filters; when both are null every
  /// article of the author is returned.
  Future<DataState<List<JournalistArticleEntity>>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  });

  /// Single article identified by [articleId].
  Future<DataState<JournalistArticleEntity>> getArticleById(String articleId);

  /// Published articles open to every reader, newest first.
  ///
  /// [authorId] restricts the results to one journalist, which is how "more
  /// articles from this author" is built on top of the same query as the
  /// general feed. [excludeArticleId] leaves out the article a reader may
  /// already be looking at. [startAfterArticleId] is the id of the last
  /// article of the previous page, used as a paging cursor.
  /// [publishedAfter] keeps the feed to a recent window; null means no limit.
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  });

  /// Stores a new article and returns it with the data owned by the backend
  /// (identifier and timestamps) already filled in.
  Future<DataState<JournalistArticleEntity>> createArticle(
    JournalistArticleEntity article,
  );

  /// Overwrites an already stored article and returns its updated version.
  Future<DataState<JournalistArticleEntity>> updateArticle(
    JournalistArticleEntity article,
  );

  /// Removes an article permanently.
  Future<DataState<void>> deleteArticle(String articleId);

  /// Rewrites the byline on every article owned by [userId], and answers how
  /// many were changed.
  ///
  /// It is a separate operation from [updateArticle] because it is not an
  /// edit: only `author` moves, so `updatedAt`, the publication date and the
  /// view count all stay as they were.
  Future<DataState<int>> updateAuthorName({
    required String userId,
    required String authorName,
  });

  /// Records that a reader opened the article identified by [articleId].
  ///
  /// This does not change the article's `updatedAt`: that field means "the
  /// author last edited this", and reader traffic is not an edit.
  Future<DataState<void>> incrementViewCount(String articleId);
}
