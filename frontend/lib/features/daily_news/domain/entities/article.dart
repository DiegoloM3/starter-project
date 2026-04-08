class ArticleEntity {
  final int ? id;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;

  // Community article fields. Both null for NewsAPI articles.
  final String ? firestoreId;
  final String ? uid;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.firestoreId,
    this.uid,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleEntity &&
        other.id == id &&
        other.author == author &&
        other.title == title &&
        other.description == description &&
        other.url == url &&
        other.urlToImage == urlToImage &&
        other.publishedAt == publishedAt &&
        other.content == content &&
        other.firestoreId == firestoreId &&
        other.uid == uid;
  }

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
        firestoreId,
        uid,
      );
}
