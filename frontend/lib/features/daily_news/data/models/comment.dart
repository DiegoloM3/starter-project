import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'articleId': articleId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
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

  static String? _timestampToString(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return null;
  }
}
