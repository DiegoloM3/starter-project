class PublishableArticle {
  final String id;
  final String author;
  final String title;
  final String description;
  final String content;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PublishableArticle({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
