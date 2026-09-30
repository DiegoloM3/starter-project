import 'package:equatable/equatable.dart';

import 'markdown_text.dart';

/// An article written by a journalist in the app and published to the backend.
///
/// See backend/docs/DB_SCHEMA.md for the stored document.
class PublishedArticleEntity extends Equatable {
  final String id;
  final String title;

  /// Body of the article in Markdown.
  final String content;

  /// Plain-text excerpt of [content] for article lists.
  final String description;
  final String author;
  final String thumbnailUrl;
  final DateTime publishedAt;

  const PublishedArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.author,
    required this.thumbnailUrl,
    required this.publishedAt,
  });

  /// Estimated minutes needed to read [content], at least 1.
  int get readingTimeInMinutes => readingTimeInMinutesOf(content);

  @override
  List<Object?> get props => [id, title, content, description, author, thumbnailUrl, publishedAt];
}
