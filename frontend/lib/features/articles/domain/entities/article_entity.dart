import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String id;
  final String authorId;
  final String categoryId;
  final String title;
  final String body;
  final String coverVerticalUrl;
  final String coverHorizontalUrl;
  final String status; // 'draft' | 'published'
  final int readTimeMinutes;
  final int saveCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final String authorName;
  final String authorAvatarUrl;

  const ArticleEntity({
    required this.id,
    required this.authorId,
    required this.categoryId,
    required this.title,
    required this.body,
    required this.coverVerticalUrl,
    required this.coverHorizontalUrl,
    required this.status,
    required this.readTimeMinutes,
    required this.saveCount,
    this.publishedAt,
    required this.createdAt,
    this.authorName = '',
    this.authorAvatarUrl = '',
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        categoryId,
        title,
        body,
        coverVerticalUrl,
        coverHorizontalUrl,
        status,
        readTimeMinutes,
        saveCount,
        publishedAt,
        createdAt,
        authorName,
        authorAvatarUrl,
      ];
}
