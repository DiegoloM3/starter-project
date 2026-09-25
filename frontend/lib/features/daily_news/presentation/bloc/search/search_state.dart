import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/search_history_entity.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Nothing searched yet: shows the recent searches instead.
class SearchIdle extends SearchState {
  final List<SearchHistoryEntity> history;

  const SearchIdle({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class SearchLoading extends SearchState {
  final String text;

  const SearchLoading(this.text);

  @override
  List<Object?> get props => [text];
}

class SearchResults extends SearchState {
  final String text;
  final List<ArticleEntity> articles;

  /// The last page loaded, 1-based.
  final int page;
  final bool hasReachedEnd;
  final bool isLoadingMore;

  const SearchResults(
    this.text, {
    required this.articles,
    this.page = 1,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
  });

  SearchResults copyWith({
    List<ArticleEntity>? articles,
    int? page,
    bool? hasReachedEnd,
    bool? isLoadingMore,
  }) {
    return SearchResults(
      text,
      articles: articles ?? this.articles,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [text, articles, page, hasReachedEnd, isLoadingMore];
}

class SearchError extends SearchState {
  final String text;

  const SearchError(this.text);

  @override
  List<Object?> get props => [text];
}
