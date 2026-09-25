import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

class UserArticleModel extends UserArticleEntity {
  const UserArticleModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.description,
    required super.content,
    required super.thumbnailURL,
    required super.createdAt,
    required super.updatedAt,
    super.isDraft,
  });

  /// [data]'s createdAt/updatedAt must already be DateTime, not a Firestore
  /// Timestamp -- converting that is the data source's job (it's the only
  /// class allowed to know cloud_firestore exists, ARCHITECTURE_VIOLATIONS.md
  /// Sec. 1.2.3/1.2.4), not this model's.
  factory UserArticleModel.fromRawData(String id, Map<String, dynamic> data) {
    return UserArticleModel(
      id: id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      content: data['content'] as String? ?? '',
      thumbnailURL: data['thumbnailURL'] as String? ?? '',
      createdAt: data['createdAt'] as DateTime? ?? DateTime.now(),
      updatedAt: data['updatedAt'] as DateTime? ?? DateTime.now(),
      isDraft: data['status'] == 'draft',
    );
  }

  /// Content fields only -- createdAt/updatedAt are server-controlled
  /// metadata (FieldValue.serverTimestamp()), which is itself a
  /// cloud_firestore-specific concern the data source adds at write time,
  /// not something this model should construct.
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailURL': thumbnailURL,
      'status': isDraft ? 'draft' : 'published',
    };
  }

  UserArticleEntity toEntity() {
    return UserArticleEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      title: title,
      description: description,
      content: content,
      thumbnailURL: thumbnailURL,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDraft: isDraft,
    );
  }
}
