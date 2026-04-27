import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

abstract class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();
}

/// Full-screen loading for initial list fetches.
class ArticlesLoading extends ArticlesState {
  const ArticlesLoading();
}

/// List is available. [isMutating] is true while a create/update/delete
/// operation is in flight — the list remains visible during the mutation.
class ArticlesLoaded extends ArticlesState {
  final List<ArticleEntity> articles;
  final bool isMutating;

  const ArticlesLoaded(this.articles, {this.isMutating = false});

  @override
  List<Object?> get props => [articles, isMutating];
}

/// Emitted when a list fetch fails.
class ArticlesError extends ArticlesState {
  final String message;

  const ArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when a create, update, or delete succeeds.
/// Always carries the updated [articles] list so the UI never loses it.
/// [article] is set for create/update; [deletedArticleId] is set for delete.
class ArticleMutationSuccess extends ArticlesState {
  final List<ArticleEntity> articles;
  final ArticleEntity? article;
  final String? deletedArticleId;

  const ArticleMutationSuccess({
    required this.articles,
    this.article,
    this.deletedArticleId,
  });

  @override
  List<Object?> get props => [articles, article, deletedArticleId];
}

/// Emitted when a create, update, or delete fails.
/// Always carries the preserved [articles] list so the UI never loses it.
class ArticleMutationError extends ArticlesState {
  final List<ArticleEntity> articles;
  final String message;

  const ArticleMutationError({
    required this.articles,
    required this.message,
  });

  @override
  List<Object?> get props => [articles, message];
}
