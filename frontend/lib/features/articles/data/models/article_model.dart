import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.excerpt,
    required super.body,
    required super.category,
    super.thumbnailURL,
    required super.authorId,
    required super.authorName,
    super.authorPhotoURL,
    required super.readTime,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ArticleModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Article document not found: ${doc.id}');
    return ArticleModel(
      id: doc.id,
      title: data['title'] as String,
      excerpt: data['excerpt'] as String,
      body: data['body'] as String,
      category: data['category'] as String,
      thumbnailURL: data['thumbnailURL'] as String?,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhotoURL: data['authorPhotoURL'] as String?,
      readTime: (data['readTime'] as num).toInt(),
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Used for new document creation. Auto-generates [excerpt] from the first
  /// 160 characters of [body], calculates [readTime], and uses server
  /// timestamps for both [createdAt] and [updatedAt].
  Map<String, dynamic> toFirestore() {
    final wordCount = body.trim().split(RegExp(r'\s+')).length;
    return {
      'title': title,
      'excerpt': body.length > 160 ? body.substring(0, 160) : body,
      'body': body,
      'category': category,
      'thumbnailURL': thumbnailURL,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoURL': authorPhotoURL,
      'readTime': (wordCount / 200).ceil(),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
