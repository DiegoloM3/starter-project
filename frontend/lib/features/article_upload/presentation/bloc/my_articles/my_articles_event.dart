import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';

sealed class MyArticlesEvent extends Equatable {
  const MyArticlesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMyArticlesEvent extends MyArticlesEvent {
  final String userId;
  const LoadMyArticlesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class DeleteArticleRequestedEvent extends MyArticlesEvent {
  final String articleId;
  const DeleteArticleRequestedEvent(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

final class MyArticlesUpdatedEvent extends MyArticlesEvent {
  final List<dynamic> articles;
  const MyArticlesUpdatedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class MyArticlesFailedEvent extends MyArticlesEvent {
  final AppException error;
  const MyArticlesFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

final class LoadDraftsEvent extends MyArticlesEvent {
  const LoadDraftsEvent();

  @override
  List<Object?> get props => [];
}

final class DraftsUpdatedEvent extends MyArticlesEvent {
  final List<DraftArticleEntity> drafts;
  const DraftsUpdatedEvent(this.drafts);

  @override
  List<Object?> get props => [drafts];
}

final class DraftsFailedEvent extends MyArticlesEvent {
  final AppException error;
  const DraftsFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

final class DeleteDraftRequestedEvent extends MyArticlesEvent {
  final int draftId;
  const DeleteDraftRequestedEvent(this.draftId);

  @override
  List<Object?> get props => [draftId];
}
