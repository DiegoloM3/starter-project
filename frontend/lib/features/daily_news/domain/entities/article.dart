class ArticleEntity {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          author == other.author &&
          title == other.title &&
          description == other.description &&
          url == other.url &&
          urlToImage == other.urlToImage &&
          publishedAt == other.publishedAt &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
        id,
        author,
        title,
        description,
        url,
        urlToImage,
        publishedAt,
        content,
      );
}
