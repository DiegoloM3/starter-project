/// Article published by a registered journalist.
class CommunityArticleEntity {
  final String id;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;
  final String thumbnailPath;
  final String payloadHash;
  final String ownerUid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommunityArticleEntity({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.thumbnailPath,
    required this.payloadHash,
    required this.ownerUid,
    this.createdAt,
    this.updatedAt,
  });
}
