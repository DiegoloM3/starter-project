import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

/// Comment as it is stored in the Firestore subcollection `articles/{articleId}/comments`
/// (backend/docs/DB_SCHEMA.md).
class ArticleCommentModel extends ArticleCommentEntity {
  const ArticleCommentModel({
    required super.id,
    required super.content,
    required super.author,
    required super.authorId,
    required super.createdAt,
  });

  /// [rawData] holds the document fields with `createdAt` already converted to a [DateTime].
  factory ArticleCommentModel.fromRawData(String id, Map<String, dynamic> rawData) {
    return ArticleCommentModel(
      id: id,
      content: rawData['content'] as String,
      author: rawData['author'] as String,
      authorId: rawData['authorId'] as String,
      createdAt: rawData['createdAt'] as DateTime,
    );
  }

  /// Fields that the journalist wrote in a new comment, without the spaces around it. The data source adds
  /// the author, taken from the signed-in account, and `createdAt`, set by the server.
  static Map<String, dynamic> buildRawDataOfNewComment(ArticleCommentDraftEntity draft) {
    return {'content': draft.content.trim()};
  }

  ArticleCommentEntity toEntity() {
    return ArticleCommentEntity(
      id: id,
      content: content,
      author: author,
      authorId: authorId,
      createdAt: createdAt,
    );
  }
}
