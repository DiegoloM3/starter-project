import '../../domain/entities/community_article.dart';

class CommunityArticleModel extends CommunityArticleEntity {
  const CommunityArticleModel({
    required super.id,
    required super.author,
    required super.title,
    required super.description,
    required super.url,
    required super.urlToImage,
    required super.publishedAt,
    required super.content,
    required super.thumbnailPath,
    required super.payloadHash,
    required super.ownerUid,
    super.createdAt,
    super.updatedAt,
  });

  factory CommunityArticleModel.fromRawData(Map<String, dynamic> data) {
    DateTime? asDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    final publishedAt = asDate(data['publishedAt']);
    return CommunityArticleModel(
      id: data['id'] as String? ?? '',
      author: data['author'] as String? ?? 'Case Study Symmetry journalist',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      url: data['url'] as String? ?? '',
      urlToImage: data['urlToImage'] as String? ?? '',
      publishedAt: publishedAt?.toIso8601String() ?? '',
      content: data['content'] as String? ?? '',
      thumbnailPath: data['thumbnailPath'] as String? ?? '',
      payloadHash: data['payloadHash'] as String? ?? '',
      ownerUid: data['ownerUid'] as String? ?? '',
      createdAt: asDate(data['createdAt']),
      updatedAt: asDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toRawData() => {
        'id': id,
        'author': author,
        'title': title,
        'description': description,
        'url': url,
        'urlToImage': urlToImage,
        'publishedAt': publishedAt,
        'content': content,
        'thumbnailPath': thumbnailPath,
        'payloadHash': payloadHash,
        'ownerUid': ownerUid,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  CommunityArticleEntity toEntity() => this;
}
