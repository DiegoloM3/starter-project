import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    super.id,
    required super.articleId,
    required super.authorId,
    super.authorName,
    super.authorPhotoUrl,
    required super.text,
    required super.createdAt,
    super.replyTo,
    super.isDeleted,
  });

  factory CommentModel.fromRawData({
    required String articleId,
    required String id,
    required Map<String, dynamic> data,
  }) {
    return CommentModel(
      id: id,
      articleId: articleId,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String?,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
      replyTo: data['replyTo'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        if (authorName != null) 'authorName': authorName,
        if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
        'text': text,
        'isDeleted': isDeleted,
        if (replyTo != null) 'replyTo': replyTo,
      };

  CommentEntity toEntity() => CommentEntity(
        id: id,
        articleId: articleId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        text: text,
        createdAt: createdAt,
        replyTo: replyTo,
        isDeleted: isDeleted,
      );
}
