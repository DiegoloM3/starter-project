import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article_upload_entity.dart';

class ArticleUploadModel extends ArticleUploadEntity {
  const ArticleUploadModel({
    super.id,
    required super.title,
    required super.content,
    required super.thumbnailUrl,
    required super.authorId,
    required super.authorName,
    required super.createdAt,
    required super.updatedAt,
    required super.readTime,
    required super.tags,
    required super.isPublished,
    super.views,
    super.likes,
  });

  factory ArticleUploadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleUploadModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      readTime: data['readTime'] ?? 1,
      tags: List<String>.from(data['tags'] ?? []),
      isPublished: data['isPublished'] ?? false,
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'thumbnailUrl': thumbnailUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'readTime': readTime,
      'tags': tags,
      'isPublished': isPublished,
      'views': views,
      'likes': likes,
    };
  }

  ArticleUploadEntity toEntity() => ArticleUploadEntity(
        id: id,
        title: title,
        content: content,
        thumbnailUrl: thumbnailUrl,
        authorId: authorId,
        authorName: authorName,
        createdAt: createdAt,
        updatedAt: updatedAt,
        readTime: readTime,
        tags: tags,
        isPublished: isPublished,
        views: views,
        likes: likes,
      );
}
