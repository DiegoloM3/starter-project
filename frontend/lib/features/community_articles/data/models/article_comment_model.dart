import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/article_comment.dart';

class ArticleCommentModel extends ArticleCommentEntity {
  const ArticleCommentModel({
    required super.id,
    required super.authorUid,
    required super.authorName,
    required super.body,
    super.createdAt,
  });

  factory ArticleCommentModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];
    DateTime? createdAt;
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    }
    return ArticleCommentModel(
      id: document.id,
      authorUid: data['authorUid'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Community reader',
      body: data['body'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
