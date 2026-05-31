import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import '../../domain/entities/article.dart';

sealed class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Failure? failure;

  const RemoteArticlesState({this.articles, this.failure});

  @override
  List<Object?> get props => [articles, failure];
}

/// Loading state for initial article fetch.
final class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

/// Success state with articles and pagination metadata.
final class RemoteArticlesDone extends RemoteArticlesState {
  /// The current page number (1-based).
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  /// Whether currently loading more articles (for infinite scroll).
  final bool isLoadingMore;

  const RemoteArticlesDone(
    List<ArticleEntity> articles, {
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  }) : super(articles: articles);

  @override
  List<Object?> get props => [
    articles,
    currentPage,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// Error state when article fetch fails.
final class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(Failure failure) : super(failure: failure);
}
