import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Length limits for an article. They mirror the Firestore security rules in
/// `backend/firestore.rules`, so a draft that passes here is accepted by the
/// backend.
abstract final class ArticleLimits {
  static const int titleMaxLength = 150;
  static const int descriptionMaxLength = 300;
  static const int contentMaxLength = 20000;
}

enum ArticleValidationError {
  emptyTitle('Give your article a title.'),
  titleTooLong('The title cannot exceed ${ArticleLimits.titleMaxLength} characters.'),
  descriptionTooLong(
      'The summary cannot exceed ${ArticleLimits.descriptionMaxLength} characters.'),
  emptyContent('Write the body of your article.'),
  contentTooLong(
      'The body cannot exceed ${ArticleLimits.contentMaxLength} characters.');

  final String message;

  const ArticleValidationError(this.message);
}

/// What a journalist types before an article exists in the backend.
///
/// Whitespace-only fields count as empty. Validation lives here, in the
/// domain, so every entry point (publish, edit) applies the same rules.
class ArticleDraft extends Equatable {
  final String title;
  final String content;
  final String? description;
  final NewsCategory category;
  final DateTime publishedAt;

  const ArticleDraft({
    required this.title,
    required this.content,
    required this.publishedAt,
    this.category = NewsCategory.general,
    this.description,
  });

  String get trimmedTitle => title.trim();

  String get trimmedContent => content.trim();

  /// `null` when the summary is absent or blank.
  String? get trimmedDescription {
    final value = description?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  List<ArticleValidationError> validate() {
    final errors = <ArticleValidationError>[];

    if (trimmedTitle.isEmpty) {
      errors.add(ArticleValidationError.emptyTitle);
    } else if (trimmedTitle.length > ArticleLimits.titleMaxLength) {
      errors.add(ArticleValidationError.titleTooLong);
    }

    final summary = trimmedDescription;
    if (summary != null && summary.length > ArticleLimits.descriptionMaxLength) {
      errors.add(ArticleValidationError.descriptionTooLong);
    }

    if (trimmedContent.isEmpty) {
      errors.add(ArticleValidationError.emptyContent);
    } else if (trimmedContent.length > ArticleLimits.contentMaxLength) {
      errors.add(ArticleValidationError.contentTooLong);
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  ArticleDraft copyWith({
    String? title,
    String? content,
    String? description,
    NewsCategory? category,
    DateTime? publishedAt,
  }) {
    return ArticleDraft(
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [title, content, description, category, publishedAt];
}
