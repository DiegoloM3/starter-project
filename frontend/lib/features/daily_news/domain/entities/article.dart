class ArticleEntity {
  final int ? id;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;

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

  /// Date the article was published, or null when it is unknown.
  DateTime? get publicationDate => DateTime.tryParse(publishedAt ?? '');

  /// Whether the article was written by a journalist of the app instead of
  /// coming from the news API.
  bool get isWrittenByJournalist => false;

  /// Full text shown in the detail of the article. The description is only
  /// added when it is not already the beginning of the content, as happens
  /// with the articles published by journalists.
  String get body {
    final text = content ?? '';
    final summary = (description ?? '').replaceFirst(RegExp(r'…$'), '');
    if (summary.isEmpty || convertToPlainText(text).startsWith(summary)) {
      return text;
    }
    return '$description\n\n$text';
  }

  /// Text of [formattedText] on a single line, without the Markdown marks
  /// journalists can use: bold (`**`) and subheadings (`#`).
  static String convertToPlainText(String formattedText) {
    return formattedText
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        .replaceAll('**', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleEntity &&
        other.id == id &&
        other.author == author &&
        other.title == title &&
        other.description == description &&
        other.url == url &&
        other.urlToImage == urlToImage &&
        other.publishedAt == publishedAt &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(
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
}
