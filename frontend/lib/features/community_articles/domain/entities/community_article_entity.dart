import 'package:equatable/equatable.dart';

/// Represents a news article created by a community user and stored in Firestore.
///
/// Uses a [String] ID (Firestore document ID) and [DateTime] timestamps,
/// intentionally distinct from [ArticleEntity] which maps to the remote news API.
class CommunityArticleEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String? description;
  final String? imageUrl;
  final String? category;
  final DateTime publishedAt;
  final DateTime? updatedAt;

  const CommunityArticleEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    this.description,
    this.imageUrl,
    this.category,
    required this.publishedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    title,
    content,
    description,
    imageUrl,
    category,
    publishedAt,
    updatedAt,
  ];
}
