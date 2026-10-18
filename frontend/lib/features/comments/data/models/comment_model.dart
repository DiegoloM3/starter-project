import '../../domain/entities/comment.dart';

/// Comment stored in `articles/{articleId}/comments/{commentId}`. The data source converts the
/// Firestore timestamps to [DateTime] first, so this model does not depend on Firebase.
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.articleId,
    required super.authorId,
    required super.authorName,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromRawData(String id, String articleId, Map<String, dynamic> data) {
    return CommentModel(
      id: id,
      articleId: articleId,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      // Null while the server has not set it yet, right after commenting without connection.
      createdAt: data['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      articleId: articleId,
      authorId: authorId,
      authorName: authorName,
      text: text,
      createdAt: createdAt,
    );
  }
}
