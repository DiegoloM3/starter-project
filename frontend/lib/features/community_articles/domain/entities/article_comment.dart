/// A public comment attached to a published community article.
class ArticleCommentEntity {
  final String id;
  final String authorUid;
  final String authorName;
  final String body;
  final DateTime? createdAt;

  const ArticleCommentEntity({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.body,
    this.createdAt,
  });
}
