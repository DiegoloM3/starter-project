import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

class FirebaseArticleModel extends ArticleEntity {
  final String documentId;

  const FirebaseArticleModel({
    required this.documentId,
    String? author,
    String? authorId,
    String? title,
    String? description,
    String? urlToImage,
    String? publishedAt,
    String? content,
  }) : super(
          author: author,
          authorId: authorId,
          title: title,
          description: description,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
        );

  factory FirebaseArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseArticleModel(
      documentId: doc.id,
      author: data['author'] ?? '',
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      urlToImage: data['thumbnailURL'] ?? '',
      publishedAt: data['publishedAt'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'authorId': authorId,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailURL': urlToImage,
      'publishedAt': publishedAt,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      author: author,
      authorId: authorId,
      title: title,
      description: description,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
    );
  }
}
