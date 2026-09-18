import 'package:equatable/equatable.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/entities/publishable_article.dart';
import '../../domain/use_cases/publish_article_result.dart';

enum PublishArticleStatus {
  initial,
  submitting,
  confirmationPending,
  validationFailure,
  success,
  failure,
}

class PublishArticleState extends Equatable {
  final String author;
  final String title;
  final String description;
  final String content;
  final ArticleThumbnail? thumbnail;
  final PublishArticleStatus status;
  final List<PublishArticleValidationError> validationErrors;
  final PublishableArticle? publishedArticle;
  final String? failureMessage;
  final String? pendingArticleId;

  static const confirmationPendingMessage =
      'Publication confirmation is pending. The article may still be published. '
      'You can go back or check confirmation; no new article will be submitted.';

  PublishArticleState({
    this.author = '',
    this.title = '',
    this.description = '',
    this.content = '',
    this.thumbnail,
    this.status = PublishArticleStatus.initial,
    List<PublishArticleValidationError> validationErrors = const [],
    this.publishedArticle,
    this.failureMessage,
    this.pendingArticleId,
  }) : validationErrors =
            List<PublishArticleValidationError>.unmodifiable(validationErrors);

  PublishArticleState copyWith({
    String? author,
    String? title,
    String? description,
    String? content,
    ArticleThumbnail? thumbnail,
    bool clearThumbnail = false,
    PublishArticleStatus? status,
    List<PublishArticleValidationError>? validationErrors,
    PublishableArticle? publishedArticle,
    bool clearPublishedArticle = false,
    String? failureMessage,
    bool clearFailureMessage = false,
    String? pendingArticleId,
    bool clearPendingArticle = false,
  }) {
    return PublishArticleState(
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnail: clearThumbnail ? null : thumbnail ?? this.thumbnail,
      status: status ?? this.status,
      validationErrors: validationErrors ?? this.validationErrors,
      publishedArticle: clearPublishedArticle
          ? null
          : publishedArticle ?? this.publishedArticle,
      failureMessage:
          clearFailureMessage ? null : failureMessage ?? this.failureMessage,
      pendingArticleId: clearPendingArticle
          ? null
          : pendingArticleId ?? this.pendingArticleId,
    );
  }

  String? errorFor(PublishArticleField field) {
    for (final error in validationErrors) {
      if (error.field == field) {
        return error.message;
      }
    }

    return null;
  }

  String? get thumbnailError {
    return errorFor(PublishArticleField.thumbnailBytes) ??
        errorFor(PublishArticleField.thumbnailMimeType) ??
        errorFor(PublishArticleField.thumbnailFileName);
  }

  bool get isSubmitting => status == PublishArticleStatus.submitting;

  bool get isSuccess => status == PublishArticleStatus.success;

  bool get isConfirmationPending =>
      status == PublishArticleStatus.confirmationPending;

  bool get isFormLocked => isSubmitting || isConfirmationPending;

  @override
  List<Object?> get props => [
        author,
        title,
        description,
        content,
        thumbnail,
        status,
        validationErrors,
        publishedArticle,
        failureMessage,
        pendingArticleId,
      ];
}
