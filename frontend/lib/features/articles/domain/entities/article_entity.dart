import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final String body;
  final String category;
  final String? thumbnailURL;
  final String authorId;
  final String authorName;
  final String? authorPhotoURL;
  final int readTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.body,
    required this.category,
    this.thumbnailURL,
    required this.authorId,
    required this.authorName,
    this.authorPhotoURL,
    required this.readTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        excerpt,
        body,
        category,
        thumbnailURL,
        authorId,
        authorName,
        authorPhotoURL,
        readTime,
        status,
        createdAt,
        updatedAt,
      ];
}
