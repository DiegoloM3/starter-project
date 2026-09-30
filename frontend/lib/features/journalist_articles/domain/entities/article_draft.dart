import 'package:equatable/equatable.dart';

import 'article_thumbnail.dart';
import 'markdown_text.dart';

enum ArticleDraftError {
  titleEmpty,
  titleTooLong,
  contentEmpty,
  contentTooLong,
  authorEmpty,
  authorTooLong,
  thumbnailMissing,
  thumbnailUnsupportedFormat,
  thumbnailTooLarge,
}

/// An article being written by a journalist, before it is published.
///
/// Holds the publishing business rules, which mirror `backend/firestore.rules`
/// (see backend/docs/DB_SCHEMA.md). Lengths are UTF-16 code units
/// ([String.length]), exactly what the security rules measure.
class ArticleDraftEntity extends Equatable {
  static const int titleMaxLength = 100;
  static const int contentMaxLength = 10000;
  static const int authorMaxLength = 60;
  static const int descriptionMaxLength = 300;

  static const _titleRule = _TextFieldRule(
    maxLength: titleMaxLength,
    emptyError: ArticleDraftError.titleEmpty,
    tooLongError: ArticleDraftError.titleTooLong,
  );
  static const _contentRule = _TextFieldRule(
    maxLength: contentMaxLength,
    emptyError: ArticleDraftError.contentEmpty,
    tooLongError: ArticleDraftError.contentTooLong,
  );
  static const _authorRule = _TextFieldRule(
    maxLength: authorMaxLength,
    emptyError: ArticleDraftError.authorEmpty,
    tooLongError: ArticleDraftError.authorTooLong,
  );

  final String title;

  /// Body of the article in Markdown.
  final String content;
  final String author;
  final ArticleThumbnailEntity? thumbnail;

  const ArticleDraftEntity({
    this.title = '',
    this.content = '',
    this.author = '',
    this.thumbnail,
  });

  ArticleDraftEntity withTitle(String title) {
    return ArticleDraftEntity(title: title, content: content, author: author, thumbnail: thumbnail);
  }

  ArticleDraftEntity withContent(String content) {
    return ArticleDraftEntity(title: title, content: content, author: author, thumbnail: thumbnail);
  }

  ArticleDraftEntity withAuthor(String author) {
    return ArticleDraftEntity(title: title, content: content, author: author, thumbnail: thumbnail);
  }

  ArticleDraftEntity withThumbnail(ArticleThumbnailEntity thumbnail) {
    return ArticleDraftEntity(title: title, content: content, author: author, thumbnail: thumbnail);
  }

  /// The draft as it must be published: text fields without surrounding whitespace.
  ArticleDraftEntity trimmed() {
    return ArticleDraftEntity(
      title: title.trim(),
      content: content.trim(),
      author: author.trim(),
      thumbnail: thumbnail,
    );
  }

  Set<ArticleDraftError> get errors {
    return [
      _titleRule.errorFor(title),
      _contentRule.errorFor(content),
      _authorRule.errorFor(author),
      _thumbnailError,
    ].whereType<ArticleDraftError>().toSet();
  }

  bool get isValid => errors.isEmpty;

  /// Nothing written or picked yet. The signature alone does not count: it is prefilled from the
  /// journalist's previous article.
  bool get isBlank => title.trim().isEmpty && content.trim().isEmpty && thumbnail == null;

  /// Words written so far in [content], without Markdown syntax.
  int get wordCount => wordCountOf(content);

  /// Estimated minutes readers will need, at least 1.
  int get readingTimeInMinutes => readingTimeInMinutesOf(content);

  /// Plain-text excerpt of [content] shown in article lists.
  String get description {
    return _truncateWithoutSplittingCharacters(markdownToPlainText(content), descriptionMaxLength);
  }

  ArticleDraftError? get _thumbnailError {
    final thumbnail = this.thumbnail;
    if (thumbnail == null) return ArticleDraftError.thumbnailMissing;
    if (!thumbnail.isSupportedFormat) return ArticleDraftError.thumbnailUnsupportedFormat;
    if (thumbnail.exceedsMaxSize) return ArticleDraftError.thumbnailTooLarge;
    return null;
  }

  @override
  List<Object?> get props => [title, content, author, thumbnail];
}

class _TextFieldRule {
  final int maxLength;
  final ArticleDraftError emptyError;
  final ArticleDraftError tooLongError;

  const _TextFieldRule({required this.maxLength, required this.emptyError, required this.tooLongError});

  ArticleDraftError? errorFor(String value) {
    if (value.trim().isEmpty) return emptyError;
    if (value.length > maxLength) return tooLongError;
    return null;
  }
}

String _truncateWithoutSplittingCharacters(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  final endsInsideSurrogatePair = _isHighSurrogate(text.codeUnitAt(maxLength - 1));
  return text.substring(0, endsInsideSurrogatePair ? maxLength - 1 : maxLength);
}

bool _isHighSurrogate(int codeUnit) => codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
