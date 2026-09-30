import 'package:equatable/equatable.dart';

import '../../../domain/entities/published_article.dart';

sealed class PublishedArticlesState extends Equatable {
  const PublishedArticlesState();

  @override
  List<Object?> get props => [];
}

final class PublishedArticlesLoading extends PublishedArticlesState {
  const PublishedArticlesLoading();
}

final class PublishedArticlesLoaded extends PublishedArticlesState {
  final List<PublishedArticleEntity> articles;

  /// Whether another page may exist after [articles].
  final bool hasMore;
  final bool isLoadingMore;

  const PublishedArticlesLoaded({required this.articles, required this.hasMore, this.isLoadingMore = false});

  PublishedArticlesLoaded startLoadingMore() {
    return PublishedArticlesLoaded(articles: articles, hasMore: hasMore, isLoadingMore: true);
  }

  PublishedArticlesLoaded stopLoadingMore() {
    return PublishedArticlesLoaded(articles: articles, hasMore: hasMore);
  }

  @override
  List<Object?> get props => [articles, hasMore, isLoadingMore];
}

final class PublishedArticlesError extends PublishedArticlesState {
  final Exception error;

  const PublishedArticlesError(this.error);

  @override
  List<Object?> get props => [error];
}
