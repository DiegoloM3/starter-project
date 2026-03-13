import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_article.dart';

/// Status of the article editor
enum ArticleEditorStatus {
  initial,
  editing,
  uploading,
  saving,
  publishing,
  success,
  error,
}

/// State for the article editor
class ArticleEditorState extends Equatable {
  final ArticleEditorStatus status;
  final String? id;
  final String title;
  final String content;
  final String? coverImageUrl;
  final String? localImagePath;
  final List<String> categories;
  final bool isDraft;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;
  final int wordCount;
  final DateTime? lastSaved;

  const ArticleEditorState({
    this.status = ArticleEditorStatus.initial,
    this.id,
    this.title = '',
    this.content = '',
    this.coverImageUrl,
    this.localImagePath,
    this.categories = const [],
    this.isDraft = true,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
    this.wordCount = 0,
    this.lastSaved,
  });

  /// Check if the form has any content
  bool get hasContent => title.isNotEmpty || content.isNotEmpty;

  /// Check if the form is valid for publishing (image is optional)
  bool get isValidForPublish => title.isNotEmpty && content.isNotEmpty;

  /// Check if the form is valid for saving as draft
  bool get isValidForDraft => title.isNotEmpty;

  /// Check if there are unsaved changes
  bool get hasUnsavedChanges =>
      hasContent && lastSaved == null || status == ArticleEditorStatus.editing;

  /// Calculate reading time in minutes (average 200 words per minute)
  int get readingTimeMinutes => (wordCount / 200).ceil();

  @override
  List<Object?> get props => [
        status,
        id,
        title,
        content,
        coverImageUrl,
        localImagePath,
        categories,
        isDraft,
        isEditing,
        errorMessage,
        successMessage,
        wordCount,
        lastSaved,
      ];

  ArticleEditorState copyWith({
    ArticleEditorStatus? status,
    String? id,
    String? title,
    String? content,
    String? coverImageUrl,
    String? localImagePath,
    List<String>? categories,
    bool? isDraft,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
    int? wordCount,
    DateTime? lastSaved,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearLocalImage = false,
  }) {
    return ArticleEditorState(
      status: status ?? this.status,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      localImagePath:
          clearLocalImage ? null : (localImagePath ?? this.localImagePath),
      categories: categories ?? this.categories,
      isDraft: isDraft ?? this.isDraft,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      wordCount: wordCount ?? this.wordCount,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  /// Create state from an existing article entity
  factory ArticleEditorState.fromEntity(UserArticleEntity article) {
    final wordCount = article.content?.split(RegExp(r'\s+')).length ?? 0;
    return ArticleEditorState(
      status: ArticleEditorStatus.editing,
      id: article.id,
      title: article.title ?? '',
      content: article.content ?? '',
      coverImageUrl: article.thumbnailUrl,
      categories: article.categories ?? const [],
      isDraft: article.isDraft,
      isEditing: true,
      wordCount: wordCount,
    );
  }
}
