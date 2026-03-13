import 'package:equatable/equatable.dart';

/// Base class for all user articles events
abstract class UserArticlesEvent extends Equatable {
  const UserArticlesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user's articles (drafts and published)
class LoadUserArticles extends UserArticlesEvent {
  final String userId;

  const LoadUserArticles({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load only published articles
class LoadPublishedArticles extends UserArticlesEvent {
  const LoadPublishedArticles();
}

/// Event to load articles by category
class LoadArticlesByCategory extends UserArticlesEvent {
  final String category;

  const LoadArticlesByCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Event to refresh the articles list
class RefreshUserArticles extends UserArticlesEvent {
  const RefreshUserArticles();
}

/// Event to delete an article
class DeleteArticle extends UserArticlesEvent {
  final String articleId;

  const DeleteArticle({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

/// Event to publish a draft article
class PublishArticle extends UserArticlesEvent {
  final String articleId;

  const PublishArticle({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

/// Event to unpublish an article (convert back to draft)
class UnpublishArticle extends UserArticlesEvent {
  final String articleId;

  const UnpublishArticle({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

/// Event to filter articles by tab (all, published, drafts)
class FilterArticles extends UserArticlesEvent {
  final ArticleFilter filter;

  const FilterArticles({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Filter types for My Articles page
enum ArticleFilter {
  all,
  published,
  drafts,
}
