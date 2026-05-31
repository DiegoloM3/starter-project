import '../../domain/entities/community_article_entity.dart';

/// Data model for a community article.
class CommunityArticleModel extends CommunityArticleEntity {
  const CommunityArticleModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.content,
    super.description,
    super.imageUrl,
    super.category,
    required super.publishedAt,
    super.updatedAt,
  });

  /// Creates a [CommunityArticleModel] from provider-neutral raw data.
  factory CommunityArticleModel.fromRawData(Map<String, dynamic> data) {
    return CommunityArticleModel(
      id: data['id'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String?,
      publishedAt: data['publishedAt'] as DateTime,
      updatedAt: data['updatedAt'] as DateTime?,
    );
  }

  /// Converts this model to a pure domain [CommunityArticleEntity].
  CommunityArticleEntity toEntity() {
    return CommunityArticleEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      description: description,
      imageUrl: imageUrl,
      category: category,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }
}
