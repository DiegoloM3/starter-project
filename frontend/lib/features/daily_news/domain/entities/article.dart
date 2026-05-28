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

  ArticleEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? authorId,
    String? authorName,
    String? thumbnailUrl,
    String? thumbnailPath,
    String? url,
    String? publishedAt,
    String? createdAt,
    String? updatedAt,
    String? status,
    bool? isDeleted,
    int? readingTimeMinutes,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, content,
    authorId, authorName,
    thumbnailUrl, thumbnailPath, url,
    publishedAt, createdAt, updatedAt,
    status, isDeleted, readingTimeMinutes,
  ];
}