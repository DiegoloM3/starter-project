import 'package:equatable/equatable.dart';

class ArticleUploadEntity extends Equatable {
  final String? id;
  final String title;
  final String content;
  final String thumbnailUrl;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int readTime;
  final List<String> tags;
  final bool isPublished;
  final int views;
  final int likes;

  const ArticleUploadEntity({
    this.id,
    required this.title,
    required this.content,
    required this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.readTime,
    required this.tags,
    required this.isPublished,
    this.views = 0,
    this.likes = 0,
  });

  static int calculateReadTime(String content) {
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 99);
  }

  ArticleUploadEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? thumbnailUrl,
    bool? isPublished,
  }) {
    return ArticleUploadEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorId: authorId,
      authorName: authorName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      readTime: content != null
          ? calculateReadTime(content)
          : readTime,
      tags: tags,
      isPublished: isPublished ?? this.isPublished,
      views: views,
      likes: likes,
    );
  }

  @override
  List<Object?> get props => [
        id, title, content, thumbnailUrl,
        authorId, authorName, createdAt,
        updatedAt, readTime, tags,
        isPublished, views, likes,
      ];
}
