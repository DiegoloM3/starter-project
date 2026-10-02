import 'package:news_app_clean_architecture/core/util/value_equality.dart';

/// Article published by a journalist in the app.
class JournalistArticleEntity with ValueEquality {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;

  /// ID of the author's account in Firebase Authentication.
  final String authorId;
  final String thumbnailURL;
  final DateTime publishedAt;

  /// How many comments the article has. It is counted when the articles are read, not stored in the article.
  final int commentCount;

  const JournalistArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.authorId,
    required this.thumbnailURL,
    required this.publishedAt,
    this.commentCount = 0,
  });

  @override
  List<Object?> get props =>
      [id, title, description, content, author, authorId, thumbnailURL, publishedAt, commentCount];
}
