import 'package:news_app_clean_architecture/core/util/value_equality.dart';

enum ArticleCommentDraftError { blank, tooLong }

/// Comment that a journalist is writing on an article. Its author is the signed-in journalist.
///
/// Its rules mirror the schema enforced by the backend (backend/docs/DB_SCHEMA.md).
class ArticleCommentDraftEntity with ValueEquality {
  static const int maxContentLength = 1000;

  final String articleId;
  final String content;

  const ArticleCommentDraftEntity({required this.articleId, this.content = ''});

  ArticleCommentDraftEntity copyWith({String? content}) {
    return ArticleCommentDraftEntity(articleId: articleId, content: content ?? this.content);
  }

  ArticleCommentDraftError? get contentError {
    if (content.trim().isEmpty) return ArticleCommentDraftError.blank;
    if (content.length > maxContentLength) return ArticleCommentDraftError.tooLong;
    return null;
  }

  bool get isValid => contentError == null;

  @override
  List<Object?> get props => [articleId, content];
}

/// Thrown when trying to add an [ArticleCommentDraftEntity] that breaks its rules.
class InvalidArticleCommentDraftException implements Exception {
  final ArticleCommentDraftEntity draft;

  const InvalidArticleCommentDraftException(this.draft);
}
