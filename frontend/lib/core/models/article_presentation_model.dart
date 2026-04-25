import 'package:equatable/equatable.dart';

/// Feature-agnostic presentation model for article cards.
///
/// Maps from any data-layer article (Firebase or NewsAPI) into
/// a single shape the UI widgets can consume without coupling
/// to a specific domain entity.
class ArticlePresentationModel extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final String? thumbnailURL;
  final String? category;
  final String authorName;
  final String? authorPhotoURL;
  final String publishedAt;
  final int readTime;
  final bool isFirebaseArticle;

  const ArticlePresentationModel({
    required this.id,
    required this.title,
    required this.excerpt,
    this.thumbnailURL,
    this.category,
    required this.authorName,
    this.authorPhotoURL,
    required this.publishedAt,
    required this.readTime,
    this.isFirebaseArticle = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        excerpt,
        thumbnailURL,
        category,
        authorName,
        authorPhotoURL,
        publishedAt,
        readTime,
        isFirebaseArticle,
      ];
}
