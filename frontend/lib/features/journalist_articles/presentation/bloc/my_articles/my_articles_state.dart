import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/journalist_article.dart';

enum MyArticlesStatus { initial, loading, success, failure }

/// UI state of the "My articles" screen: the list the journalist is looking
/// at, the filters applied to it and the outcome of the last operation.
class MyArticlesState extends Equatable {
  final MyArticlesStatus status;
  final List<JournalistArticleEntity> articles;

  /// When null, drafts and published articles are shown together.
  final ArticleStatus? statusFilter;
  final String searchQuery;

  /// Failure of the last operation, kept so the screen can report it once.
  final Object? error;

  const MyArticlesState({
    this.status = MyArticlesStatus.initial,
    this.articles = const [],
    this.statusFilter,
    this.searchQuery = '',
    this.error,
  });

  bool get isLoading => status == MyArticlesStatus.loading;

  bool get isEmpty => status == MyArticlesStatus.success && articles.isEmpty;

  MyArticlesState copyWith({
    MyArticlesStatus? status,
    List<JournalistArticleEntity>? articles,
    ArticleStatus? statusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
    Object? error,
    bool clearError = false,
  }) {
    return MyArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        statusFilter,
        searchQuery,
        error,
      ];
}
