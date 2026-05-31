import 'package:equatable/equatable.dart';

import 'article_source.dart';

/// Represents a bookmarked article regardless of its origin.
///
/// The composite key (sourceId + source) uniquely identifies a bookmark:
/// - For [ArticleSource.api] articles, [sourceId] is the article URL.
/// - For [ArticleSource.community] articles, [sourceId] is the Firestore document ID.
class BookmarkEntity extends Equatable {
  final String sourceId;
  final ArticleSource source;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String? author;
  final String? publishedAt;
  final String? content;

  const BookmarkEntity({
    required this.sourceId,
    required this.source,
    this.title,
    this.description,
    this.imageUrl,
    this.url,
    this.author,
    this.publishedAt,
    this.content,
  });

  @override
  List<Object?> get props => [sourceId, source];
}
