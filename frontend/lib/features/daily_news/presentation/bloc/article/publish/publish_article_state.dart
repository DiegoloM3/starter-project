import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';

enum PublishArticleStatus {
  editing,
  publishing,
  published,
  invalid,
  failure,
}

class PublishArticleState extends Equatable {
  final String title;
  final String content;
  final String? thumbnailPath;
  final PublishArticleStatus status;
  final List<ArticleDraftError> validationErrors;

  const PublishArticleState({
    this.title = '',
    this.content = '',
    this.thumbnailPath,
    this.status = PublishArticleStatus.editing,
    this.validationErrors = const [],
  });

  ArticleDraftEntity get draft {
    return ArticleDraftEntity(title: title, content: content, thumbnailPath: thumbnailPath);
  }

  bool get isPublishing => status == PublishArticleStatus.publishing;

  PublishArticleState copyWith({
    String? title,
    String? content,
    String? thumbnailPath,
    PublishArticleStatus? status,
    List<ArticleDraftError>? validationErrors,
  }) {
    return PublishArticleState(
      title: title ?? this.title,
      content: content ?? this.content,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object?> get props => [title, content, thumbnailPath, status, validationErrors];
}
