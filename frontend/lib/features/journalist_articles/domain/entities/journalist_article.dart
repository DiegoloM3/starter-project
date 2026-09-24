import 'package:equatable/equatable.dart';

import 'article_status.dart';
import 'article_failures.dart';

/// An article authored by a journalist from inside the app.
///
/// It is a different business object from the read only `ArticleEntity` of the
/// `daily_news` feature: that one is a news item fetched from an external API,
/// while this one owns a full lifecycle (draft, published, edited, deleted) and
/// belongs to the user that wrote it.
///
/// The length limits below mirror the ones documented in
/// `backend/docs/DB_SCHEMA.md`.
class JournalistArticleEntity extends Equatable {
  static const int titleMaxLength = 200;
  static const int descriptionMaxLength = 500;

  /// Identifier of the stored article. It is `null` until the article has been
  /// persisted for the first time.
  final String? id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String userId;
  final String thumbnailUrl;
  final ArticleStatus status;

  /// Number of times a reader has opened this article. It is only ever
  /// incremented by `JournalistArticleRepository.incrementViewCount`, never by
  /// editing the article, so it carries no `updatedAt` change.
  final int viewCount;

  /// Timestamps owned by the backend: they are `null` for an article that has
  /// not been stored yet.
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JournalistArticleEntity({
    this.id,
    this.title = '',
    this.description = '',
    this.content = '',
    this.author = '',
    this.userId = '',
    this.thumbnailUrl = '',
    this.status = ArticleStatus.draft,
    this.viewCount = 0,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status == ArticleStatus.draft;

  bool get isPublished => status == ArticleStatus.published;

  /// Whether the article already exists on the backend.
  bool get isStored => id != null && id!.isNotEmpty;

  /// Whether the article satisfies every rule required to be made public.
  bool get canBePublished => validateForPublishing().isEmpty;

  /// Whether this article is one of the results for [query].
  ///
  /// The rule lives here rather than where the searching happens: what counts
  /// as a match is a statement about an article, and the data source only
  /// filters in memory because Firestore has no substring search to delegate
  /// it to. An empty query matches everything, which is what "no filter"
  /// means to a reader.
  bool matches(String query) {
    final terms = query.trim().toLowerCase();

    if (terms.isEmpty) {
      return true;
    }

    return title.toLowerCase().contains(terms) ||
        description.toLowerCase().contains(terms) ||
        content.toLowerCase().contains(terms);
  }

  /// Validates the article against the rules of its current [status].
  ///
  /// A draft is allowed to be incomplete, a published article is not.
  List<ArticleValidationError> validate() {
    return isPublished ? validateForPublishing() : validateAsDraft();
  }

  /// Rules an article must satisfy to be saved as a draft.
  ///
  /// A draft only needs to be identifiable by its author, so that the
  /// journalist can keep writing it later.
  List<ArticleValidationError> validateAsDraft() {
    final errors = <ArticleValidationError>[];

    if (_isBlank(title)) {
      errors.add(ArticleValidationError.titleRequired);
    }
    if (title.length > titleMaxLength) {
      errors.add(ArticleValidationError.titleTooLong);
    }
    if (description.length > descriptionMaxLength) {
      errors.add(ArticleValidationError.descriptionTooLong);
    }
    if (_isBlank(author)) {
      errors.add(ArticleValidationError.authorRequired);
    }
    if (_isBlank(userId)) {
      errors.add(ArticleValidationError.userRequired);
    }

    return errors;
  }

  /// Rules an article must satisfy to be readable by the whole audience.
  List<ArticleValidationError> validateForPublishing() {
    final errors = validateAsDraft();

    if (_isBlank(description)) {
      errors.add(ArticleValidationError.descriptionRequired);
    }
    if (_isBlank(content)) {
      errors.add(ArticleValidationError.contentRequired);
    }
    if (_isBlank(thumbnailUrl)) {
      errors.add(ArticleValidationError.thumbnailRequired);
    }

    return errors;
  }

  /// Returns a copy of this article moved to the published state.
  ///
  /// [publishedAt] only applies the first time an article goes public. An
  /// article that is already published keeps the date it originally got:
  /// editing a published article is not publishing it again. Overwriting the
  /// date would also reorder the public feed, which sorts on it, so every
  /// edit would jump the article back to the top.
  JournalistArticleEntity markAsPublished(DateTime publishedAt) {
    return copyWith(
      status: ArticleStatus.published,
      publishedAt: this.publishedAt ?? publishedAt,
    );
  }

  /// Returns a copy of this article moved back to the draft state, hiding it
  /// from the audience without deleting it.
  ///
  /// The publication date goes with it: an article nobody can read has no
  /// date on which readers got it. `backend/firestore.rules` enforces exactly
  /// this, rejecting a draft that still carries a `publishedAt`.
  JournalistArticleEntity markAsDraft() {
    return copyWith(
      status: ArticleStatus.draft,
      clearPublishedAt: true,
    );
  }

  JournalistArticleEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? author,
    String? userId,
    String? thumbnailUrl,
    ArticleStatus? status,
    int? viewCount,
    DateTime? publishedAt,

    /// Drops the publication date, which [publishedAt] cannot do on its own:
    /// passing null there means "leave it alone".
    bool clearPublishedAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalistArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      userId: userId ?? this.userId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      publishedAt: clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static bool _isBlank(String value) => value.trim().isEmpty;

  @override
  List<Object?> get props {
    return [
      id,
      title,
      description,
      content,
      author,
      userId,
      thumbnailUrl,
      status,
      viewCount,
      publishedAt,
      createdAt,
      updatedAt,
    ];
  }
}
