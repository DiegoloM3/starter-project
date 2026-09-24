import 'package:equatable/equatable.dart';

import '../../../domain/entities/journalist_article.dart';

enum ArticleFeedStatus { initial, loading, loadingMore, success, failure }

/// UI state of a feed of published articles: the general community feed, or
/// "more articles from this journalist" when `ArticleFeedCubit` is scoped to
/// one author.
class ArticleFeedState extends Equatable {
  final ArticleFeedStatus status;
  final List<JournalistArticleEntity> articles;

  /// Whether another page can be requested with `loadMore()`.
  final bool hasMore;

  /// Failure of the last operation, kept so the screen can report it once.
  final Object? error;

  const ArticleFeedState({
    this.status = ArticleFeedStatus.initial,
    this.articles = const [],
    this.hasMore = true,
    this.error,
  });

  bool get isLoading => status == ArticleFeedStatus.loading;

  bool get isLoadingMore => status == ArticleFeedStatus.loadingMore;

  bool get isEmpty => status == ArticleFeedStatus.success && articles.isEmpty;

  ArticleFeedState copyWith({
    ArticleFeedStatus? status,
    List<JournalistArticleEntity>? articles,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return ArticleFeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, articles, hasMore, error];
}
