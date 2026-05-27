import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final String? content;
  final String? authorId;
  final String? authorName;
  final String? thumbnailUrl;
  final String? thumbnailPath;
  final String? url;
  final String? publishedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? status;
  final bool? isDeleted;
  final int? readingTimeMinutes;

  const ArticleEntity({
    this.id,
    this.title,
    this.description,
    this.content,
    this.authorId,
    this.authorName,
    this.thumbnailUrl,
    this.thumbnailPath,
    this.url,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.isDeleted,
    this.readingTimeMinutes,
  });

  @override
  List<Object?> get props => [
    id, title, description, content,
    authorId, authorName,
    thumbnailUrl, thumbnailPath, url,
    publishedAt, createdAt, updatedAt,
    status, isDeleted, readingTimeMinutes,
  ];
}