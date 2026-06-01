import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.authorId,
    required super.categoryId,
    required super.title,
    required super.body,
    required super.coverVerticalUrl,
    required super.coverHorizontalUrl,
    required super.status,
    required super.readTimeMinutes,
    required super.saveCount,
    super.publishedAt,
    required super.createdAt,
    super.authorName,
    super.authorAvatarUrl,
  });

  factory ArticleModel.fromRawData(Map<String, dynamic> data) {
    return ArticleModel(
      id: data['id'] ?? '',
      authorId: data['author_id'] ?? '',
      categoryId: data['category_id'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      coverVerticalUrl: data['cover_vertical_url'] ?? '',
      coverHorizontalUrl: data['cover_horizontal_url'] ?? '',
      status: data['status'] ?? 'draft',
      readTimeMinutes: data['read_time_minutes'] ?? 0,
      saveCount: data['save_count'] ?? 0,
      publishedAt: _parseDate(data['published_at']),
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      authorName: data['author_name'] ?? '',
      authorAvatarUrl: data['author_avatar_url'] ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
