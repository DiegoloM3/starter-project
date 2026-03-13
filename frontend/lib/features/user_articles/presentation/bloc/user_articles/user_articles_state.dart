import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_article.dart';
import 'user_articles_event.dart';

/// Base class for all user articles states
abstract class UserArticlesState extends Equatable {
  final List<UserArticleEntity>? articles;
  final List<UserArticleEntity>? filteredArticles;
  final ArticleFilter currentFilter;
  final String? errorMessage;

  const UserArticlesState({
    this.articles,
    this.filteredArticles,
    this.currentFilter = ArticleFilter.all,
    this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [articles, filteredArticles, currentFilter, errorMessage];
}

/// Initial state before loading
class UserArticlesInitial extends UserArticlesState {
  const UserArticlesInitial();
}

/// State while loading articles
class UserArticlesLoading extends UserArticlesState {
  const UserArticlesLoading();
}

/// State when articles are successfully loaded
class UserArticlesLoaded extends UserArticlesState {
  final int publishedCount;
  final int draftsCount;

  const UserArticlesLoaded({
    required List<UserArticleEntity> articles,
    List<UserArticleEntity>? filteredArticles,
    ArticleFilter currentFilter = ArticleFilter.all,
    required this.publishedCount,
    required this.draftsCount,
  }) : super(
          articles: articles,
          filteredArticles: filteredArticles ?? articles,
          currentFilter: currentFilter,
        );

  @override
  List<Object?> get props => [
        articles,
        filteredArticles,
        currentFilter,
        publishedCount,
        draftsCount,
      ];

  /// Create a copy with updated values
  UserArticlesLoaded copyWith({
    List<UserArticleEntity>? articles,
    List<UserArticleEntity>? filteredArticles,
    ArticleFilter? currentFilter,
    int? publishedCount,
    int? draftsCount,
  }) {
    return UserArticlesLoaded(
      articles: articles ?? this.articles!,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      currentFilter: currentFilter ?? this.currentFilter,
      publishedCount: publishedCount ?? this.publishedCount,
      draftsCount: draftsCount ?? this.draftsCount,
    );
  }
}

/// State when there's an error loading articles
class UserArticlesError extends UserArticlesState {
  const UserArticlesError({required String message})
      : super(errorMessage: message);
}

/// State while performing an action (delete, publish, unpublish)
class UserArticlesActionInProgress extends UserArticlesState {
  final String actionMessage;

  const UserArticlesActionInProgress({
    required this.actionMessage,
    List<UserArticleEntity>? articles,
    List<UserArticleEntity>? filteredArticles,
    ArticleFilter currentFilter = ArticleFilter.all,
  }) : super(
          articles: articles,
          filteredArticles: filteredArticles,
          currentFilter: currentFilter,
        );

  @override
  List<Object?> get props =>
      [actionMessage, articles, filteredArticles, currentFilter];
}

/// State after a successful action
class UserArticlesActionSuccess extends UserArticlesState {
  final String successMessage;

  const UserArticlesActionSuccess({
    required this.successMessage,
    List<UserArticleEntity>? articles,
    List<UserArticleEntity>? filteredArticles,
    ArticleFilter currentFilter = ArticleFilter.all,
  }) : super(
          articles: articles,
          filteredArticles: filteredArticles,
          currentFilter: currentFilter,
        );

  @override
  List<Object?> get props =>
      [successMessage, articles, filteredArticles, currentFilter];
}
