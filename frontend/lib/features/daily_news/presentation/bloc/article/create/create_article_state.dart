import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';

class CreateArticleState extends Equatable {
  final String? articleId;
  final String title;
  final String description;
  final String content;
  final String? selectedImagePath;
  final String? thumbnailUrl;
  final String? thumbnailPath;
  final String status;
  final int readingTimeMinutes;
  final bool isSaving;
  final bool isPublishing;
  final bool isPublished;
  final AppException? error;
  final DateTime? lastSavedAt;

  const CreateArticleState({
    this.articleId,
    this.title = '',
    this.description = '',
    this.content = '',
    this.selectedImagePath,
    this.thumbnailUrl,
    this.thumbnailPath,
    this.status = ArticleStatus.draft,
    this.readingTimeMinutes = 1,
    this.isSaving = false,
    this.isPublishing = false,
    this.isPublished = false,
    this.error,
    this.lastSavedAt,
  });

  bool get hasContent =>
      title.trim().isNotEmpty || content.trim().isNotEmpty;

  bool get canPublish =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      content.trim().isNotEmpty &&
      status == ArticleStatus.draft;

  bool get canArchive => status == ArticleStatus.published;

  ArticleEntity toEntity({
    required String authorId,
    required String authorName,
  }) {
    return ArticleEntity(
      id: articleId,
      title: title.trim(),
      description: description.trim(),
      content: content.trim(),
      authorId: authorId,
      authorName: authorName,
      thumbnailUrl: thumbnailUrl ?? '',
      thumbnailPath: thumbnailPath ?? '',
      status: status,
      readingTimeMinutes: readingTimeMinutes,
      isDeleted: false,
    );
  }

  CreateArticleState copyWith({
    String? articleId,
    String? title,
    String? description,
    String? content,
    String? selectedImagePath,
    String? thumbnailUrl,
    String? thumbnailPath,
    String? status,
    int? readingTimeMinutes,
    bool? isSaving,
    bool? isPublishing,
    bool? isPublished,
    AppException? error,
    DateTime? lastSavedAt,
    bool clearError = false,
    bool clearSelectedImage = false,
    bool clearThumbnailUrl = false,
  }) {
    return CreateArticleState(
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      selectedImagePath:
          clearSelectedImage ? null : (selectedImagePath ?? this.selectedImagePath),
      thumbnailUrl:
          clearThumbnailUrl ? null : (thumbnailUrl ?? this.thumbnailUrl),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      isSaving: isSaving ?? this.isSaving,
      isPublishing: isPublishing ?? this.isPublishing,
      isPublished: isPublished ?? this.isPublished,
      error: clearError ? null : (error ?? this.error),
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  List<Object?> get props => [
        articleId,
        title,
        description,
        content,
        selectedImagePath,
        thumbnailUrl,
        thumbnailPath,
        status,
        readingTimeMinutes,
        isSaving,
        isPublishing,
        isPublished,
        error,
        lastSavedAt,
      ];
}
