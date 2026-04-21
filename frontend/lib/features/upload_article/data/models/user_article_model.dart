import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';

class UserArticleModel extends UserArticleEntity {
  final String thumbnailPath;

  const UserArticleModel({
    super.id,
    required super.authorId,
    super.authorEmail,
    super.authorName,
    super.authorPhotoUrl,
    required super.title,
    required super.description,
    required super.content,
    required String super.thumbnailUrl,
    required this.thumbnailPath,
    required super.publishedAt,
  });

  factory UserArticleModel.fromRawData({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return UserArticleModel(
      id: id,
      authorId: data['authorId'] as String,
      authorEmail: data['authorEmail'] as String?,
      authorName: data['authorName'] as String?,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      title: data['title'] as String,
      description: data['description'] as String,
      content: data['content'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String,
      thumbnailPath: data['thumbnailPath'] as String,
      publishedAt: data['publishedAt'] as DateTime,
    );
  }

  /// Plain-Dart map of this model. Transport-specific concerns
  /// (e.g. server timestamps) belong in the data source that writes it.
  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        if (authorEmail != null) 'authorEmail': authorEmail,
        if (authorName != null) 'authorName': authorName,
        if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
        'title': title,
        'description': description,
        'content': content,
        'thumbnailUrl': thumbnailUrl,
        'thumbnailPath': thumbnailPath,
      };

  UserArticleEntity toEntity() => UserArticleEntity(
        id: id,
        authorId: authorId,
        authorEmail: authorEmail,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title,
        description: description,
        content: content,
        thumbnailUrl: thumbnailUrl,
        publishedAt: publishedAt,
      );
}
