class CommentEntity {
  final String? id;
  final String articleId;
  final String authorId;
  final String? authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;
  final String? replyTo;
  final bool isDeleted;

  const CommentEntity({
    this.id,
    required this.articleId,
    required this.authorId,
    this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
    this.replyTo,
    this.isDeleted = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          articleId == other.articleId &&
          authorId == other.authorId &&
          authorName == other.authorName &&
          authorPhotoUrl == other.authorPhotoUrl &&
          text == other.text &&
          createdAt == other.createdAt &&
          replyTo == other.replyTo &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode => Object.hash(
        id,
        articleId,
        authorId,
        authorName,
        authorPhotoUrl,
        text,
        createdAt,
        replyTo,
        isDeleted,
      );
}
