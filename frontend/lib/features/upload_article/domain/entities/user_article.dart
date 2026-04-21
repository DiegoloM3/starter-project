class UserArticleEntity {
  final String? id;
  final String authorId;
  final String? authorEmail;
  final String? authorName;
  final String? authorPhotoUrl;
  final String title;
  final String description;
  final String content;
  final String? thumbnailUrl;
  final DateTime publishedAt;

  const UserArticleEntity({
    this.id,
    required this.authorId,
    this.authorEmail,
    this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.description,
    required this.content,
    this.thumbnailUrl,
    required this.publishedAt,
  });

  String get byline {
    final name = authorName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return authorEmail ?? 'Unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserArticleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          authorId == other.authorId &&
          authorEmail == other.authorEmail &&
          authorName == other.authorName &&
          authorPhotoUrl == other.authorPhotoUrl &&
          title == other.title &&
          description == other.description &&
          content == other.content &&
          thumbnailUrl == other.thumbnailUrl &&
          publishedAt == other.publishedAt;

  @override
  int get hashCode => Object.hash(
        id,
        authorId,
        authorEmail,
        authorName,
        authorPhotoUrl,
        title,
        description,
        content,
        thumbnailUrl,
        publishedAt,
      );
}
