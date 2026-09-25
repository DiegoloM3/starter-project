import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';

import '../../../../domain/entities/article.dart';

/// Every state knows its [category], so the section bar can show which one
/// is selected even while it's loading or has failed.
abstract class RemoteArticlesState extends Equatable {
  final NewsCategory category;

  const RemoteArticlesState(this.category);

  @override
  List<Object?> get props => [category];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading(super.category);
}

class RemoteArticlesDone extends RemoteArticlesState {
  final List<ArticleEntity> articles;

  /// The last page loaded, 1-based.
  final int page;
  final bool hasReachedEnd;
  final bool isLoadingMore;

  /// Set when showing the copy kept on the phone, because the news couldn't
  /// be loaded: when that copy was saved.
  final DateTime? savedAt;

  /// True when [savedAt] is set specifically because NewsAPI's free-plan
  /// daily cap was hit, not because the device has no connection.
  final bool isRateLimited;

  const RemoteArticlesDone(
    super.category, {
    required this.articles,
    this.page = 1,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.savedAt,
    this.isRateLimited = false,
  });

  RemoteArticlesDone copyWith({
    List<ArticleEntity>? articles,
    int? page,
    bool? hasReachedEnd,
    bool? isLoadingMore,
  }) {
    return RemoteArticlesDone(
      category,
      articles: articles ?? this.articles,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      savedAt: savedAt,
      isRateLimited: isRateLimited,
    );
  }

  @override
  List<Object?> get props => [
        category,
        articles,
        page,
        hasReachedEnd,
        isLoadingMore,
        savedAt,
        isRateLimited,
      ];
}

class RemoteArticlesError extends RemoteArticlesState {
  final Object? error;

  const RemoteArticlesError(super.category, this.error);

  @override
  List<Object?> get props => [category, error];
}
