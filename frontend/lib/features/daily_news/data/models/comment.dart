import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    String? id,
    String? articleId,
    String? authorId,
    String? authorName,
    String? content,
    String? createdAt,
    bool? isDeleted,
  }) : super(
          id: id,
          articleId: articleId,
          authorId: authorId,
          authorName: authorName,
          content: content,
          createdAt: createdAt,
          isDeleted: isDeleted,
        );

  /// Sentinel value for `createdAt` in the plain map produced by
  /// [toFirestoreMap]. The Firestore data source replaces it with
  /// `FieldValue.serverTimestamp()` before writing — this keeps the
  /// cloud_firestore dependency out of the model layer.
  static const String serverTimestampSentinel = '__server_timestamp__';

  /// Builds a model from already-parsed plain values. The Firestore data source
  /// converts the `createdAt` `Timestamp` to an ISO-8601 string (or null) before
  /// calling this, so the model never touches a `Timestamp` directly.
  factory CommentModel.fromFirestore(Map<String, dynamic> data) {
    return CommentModel(
      id: data['id'] as String?,
      articleId: data['articleId'] as String?,
      authorId: data['authorId'] as String?,
      authorName: data['authorName'] as String?,
      content: data['content'] as String?,
      createdAt: _timestampToString(data['createdAt']),
      isDeleted: data['isDeleted'] as bool?,
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      articleId: entity.articleId,
      authorId: entity.authorId,
      authorName: entity.authorName,
      content: entity.content,
      createdAt: entity.createdAt,
      isDeleted: entity.isDeleted,
    );
  }

  /// Plain-Dart Firestore payload. `createdAt` carries
  /// [serverTimestampSentinel]; the data source translates it into
  /// `FieldValue.serverTimestamp()` on write.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'articleId': articleId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': serverTimestampSentinel,
      'isDeleted': isDeleted ?? false,
    };
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      articleId: articleId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: createdAt,
      isDeleted: isDeleted,
    );
  }

  static String? _timestampToString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return null;
  }
}
