import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

class ArticleUploadModel extends ArticleUploadEntity {
  ArticleUploadModel({
    super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.author,
    required super.authorUid,
    required super.thumbnailURL,
    super.sourceName,
    required super.publishedAt,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ArticleUploadModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Document ${snapshot.id} has no data');
    }
    return ArticleUploadModel(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      content: data['content'] as String,
      author: data['author'] as String,
      authorUid: data['authorUid'] as String,
      thumbnailURL: data['thumbnailURL'] as String,
      sourceName: data['sourceName'] as String?,
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  ArticleUploadEntity toEntity() {
    return ArticleUploadEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      author: author,
      authorUid: authorUid,
      thumbnailURL: thumbnailURL,
      sourceName: sourceName,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toFirestoreCreate(String documentId) {
    return {
      'id': documentId,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'authorUid': authorUid,
      'thumbnailURL': thumbnailURL,
      if (sourceName != null) 'sourceName': sourceName,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'thumbnailURL': thumbnailURL,
      if (sourceName != null) 'sourceName': sourceName,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> softDeletePayload() {
    return {
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
