import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_failures.dart';
import '../../domain/entities/article_status.dart';
import '../../domain/entities/journalist_article.dart';
import '../../domain/repository/journalist_article_repository.dart';

/// In memory implementation of [JournalistArticleRepository] used while the
/// Firestore data sources are not built yet (step 2.1 of the assignment asks
/// for the use cases to run on mock data).
///
/// It is a real implementation of the domain contract instead of mock data
/// hardcoded inside the use cases, so that plugging the Firestore
/// implementation later is a change in the injection container only, and the
/// use cases never have to be rewritten.
class JournalistArticleRepositoryInMemoryImpl
    implements JournalistArticleRepository {
  /// Latency added to every operation so the UI can exercise its loading
  /// states against realistic timings.
  static const Duration _simulatedLatency = Duration(milliseconds: 400);

  /// Author the seed articles belong to. Only this fixture uses it: the real
  /// implementation takes its identity from the signed in user.
  static const String _seedAuthorId = 'seed-journalist-uid';
  static const String _seedAuthorName = 'Alex Rivera';

  final List<JournalistArticleEntity> _articles;
  int _generatedIds = 0;

  JournalistArticleRepositoryInMemoryImpl({
    List<JournalistArticleEntity>? initialArticles,
  }) : _articles = List<JournalistArticleEntity>.from(
          initialArticles ?? _seedArticles,
        );

  @override
  Future<DataState<List<JournalistArticleEntity>>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  }) async {
    await _simulateLatency();

    final matches = _articles
        .where((article) => article.userId == userId)
        .where((article) => status == null || article.status == status)
        .where((article) => _matchesQuery(article, searchQuery))
        .toList();

    matches.sort(_byMostRecentFirst);

    return DataSuccess(matches);
  }

  @override
  Future<DataState<JournalistArticleEntity>> getArticleById(
    String articleId,
  ) async {
    await _simulateLatency();

    final index = _indexOf(articleId);
    if (index == -1) {
      return DataFailed(ArticleNotFoundException(articleId));
    }

    return DataSuccess(_articles[index]);
  }

  @override
  Future<DataState<JournalistArticleEntity>> createArticle(
    JournalistArticleEntity article,
  ) async {
    await _simulateLatency();

    final now = DateTime.now();
    _generatedIds++;
    final created = article.copyWith(
      id: 'mock-article-$_generatedIds',
      createdAt: now,
      updatedAt: now,
      publishedAt: article.isPublished ? now : null,
    );
    _articles.add(created);

    return DataSuccess(created);
  }

  @override
  Future<DataState<JournalistArticleEntity>> updateArticle(
    JournalistArticleEntity article,
  ) async {
    await _simulateLatency();

    final index = _indexOf(article.id);
    if (index == -1) {
      return DataFailed(ArticleNotFoundException(article.id ?? ''));
    }

    final updated = article.copyWith(updatedAt: DateTime.now());
    _articles[index] = updated;

    return DataSuccess(updated);
  }

  @override
  Future<DataState<int>> updateAuthorName({
    required String userId,
    required String authorName,
  }) async {
    await _simulateLatency();

    var renamed = 0;

    for (var index = 0; index < _articles.length; index++) {
      final article = _articles[index];

      if (article.userId != userId || article.author == authorName) {
        continue;
      }

      // Only the byline moves: `updatedAt` stays where it was, because being
      // renamed is not an edit.
      _articles[index] = article.copyWith(author: authorName);
      renamed++;
    }

    return DataSuccess(renamed);
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    await _simulateLatency();

    final index = _indexOf(articleId);
    if (index == -1) {
      return DataFailed(ArticleNotFoundException(articleId));
    }

    _articles.removeAt(index);

    return const DataSuccess(null);
  }

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) async {
    await _simulateLatency();

    var matches = _articles
        .where((article) => article.isPublished)
        .where((article) => authorId == null || article.userId == authorId)
        .where((article) => article.id != excludeArticleId)
        .where((article) => _isInsideWindow(article, publishedAfter))
        .toList();

    matches.sort(_byMostRecentlyPublishedFirst);

    if (startAfterArticleId != null) {
      final cursorIndex =
          matches.indexWhere((article) => article.id == startAfterArticleId);
      if (cursorIndex != -1) {
        matches = matches.sublist(cursorIndex + 1);
      }
    }

    return DataSuccess(matches.take(limit).toList());
  }

  @override
  Future<DataState<void>> incrementViewCount(String articleId) async {
    await _simulateLatency();

    final index = _indexOf(articleId);
    if (index == -1) {
      return DataFailed(ArticleNotFoundException(articleId));
    }

    _articles[index] = _articles[index].copyWith(
      viewCount: _articles[index].viewCount + 1,
    );

    return const DataSuccess(null);
  }

  /// An article with no publication date never passes a time window: it was
  /// never published, so it has no date to be inside one.
  bool _isInsideWindow(
    JournalistArticleEntity article,
    DateTime? publishedAfter,
  ) {
    if (publishedAfter == null) {
      return true;
    }

    final publishedAt = article.publishedAt;

    return publishedAt != null && !publishedAt.isBefore(publishedAfter);
  }

  Future<void> _simulateLatency() => Future.delayed(_simulatedLatency);

  int _indexOf(String? articleId) {
    return _articles.indexWhere((article) => article.id == articleId);
  }

  bool _matchesQuery(JournalistArticleEntity article, String? searchQuery) {
    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return true;
    }

    final query = searchQuery.trim().toLowerCase();

    return article.title.toLowerCase().contains(query) ||
        article.description.toLowerCase().contains(query) ||
        article.content.toLowerCase().contains(query);
  }

  int _byMostRecentFirst(
    JournalistArticleEntity first,
    JournalistArticleEntity second,
  ) {
    final firstDate = first.updatedAt ?? first.createdAt;
    final secondDate = second.updatedAt ?? second.createdAt;

    if (firstDate == null || secondDate == null) {
      return 0;
    }

    return secondDate.compareTo(firstDate);
  }

  /// Unlike [_byMostRecentFirst] (used for the author's own list, which cares
  /// about the last edit), the public feed orders by when an article went
  /// live, since that is what "newest" means to a reader.
  int _byMostRecentlyPublishedFirst(
    JournalistArticleEntity first,
    JournalistArticleEntity second,
  ) {
    final firstDate = first.publishedAt ?? first.createdAt;
    final secondDate = second.publishedAt ?? second.createdAt;

    if (firstDate == null || secondDate == null) {
      return 0;
    }

    return secondDate.compareTo(firstDate);
  }

  static final List<JournalistArticleEntity> _seedArticles = [
    JournalistArticleEntity(
      id: 'mock-article-seed-1',
      title: 'Local newsroom brings back the neighbourhood beat',
      description:
          'A small team of reporters covers the streets no national outlet '
          'visits, and readers are showing up for it.',
      content:
          'When the city newspaper closed its local desk, three reporters kept '
          'walking the same streets anyway. Two years later their newsletter '
          'reaches more households than the paper ever did, and the city '
          'council has started answering their questions again.',
      author: _seedAuthorName,
      userId: _seedAuthorId,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1495020689067-958852a7765e',
      status: ArticleStatus.published,
      publishedAt: DateTime(2026, 9, 18, 9, 30),
      createdAt: DateTime(2026, 9, 17, 18, 5),
      updatedAt: DateTime(2026, 9, 18, 9, 30),
    ),
    JournalistArticleEntity(
      id: 'mock-article-seed-2',
      title: 'How the new transit plan changes your commute',
      description:
          'Three lines, one new interchange and a fare system nobody has '
          'explained yet.',
      content: 'The transit authority published a 180 page plan on a Friday '
          'afternoon. We read it so you do not have to, and asked the people '
          'who ride the lines every morning what they think of it.',
      author: _seedAuthorName,
      userId: _seedAuthorId,
      thumbnailUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
      status: ArticleStatus.published,
      publishedAt: DateTime(2026, 9, 12, 7, 0),
      createdAt: DateTime(2026, 9, 11, 21, 40),
      updatedAt: DateTime(2026, 9, 12, 7, 0),
    ),
    JournalistArticleEntity(
      id: 'mock-article-seed-3',
      title: 'Interview with the last night bus driver (draft)',
      description: '',
      content: 'Notes from the ride: leaves the depot at 23:40, knows every '
          'passenger by name. Needs a second interview and photos before this '
          'one can go out.',
      author: _seedAuthorName,
      userId: _seedAuthorId,
      status: ArticleStatus.draft,
      createdAt: DateTime(2026, 9, 20, 23, 55),
      updatedAt: DateTime(2026, 9, 21, 1, 10),
    ),
  ];
}
