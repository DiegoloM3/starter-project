import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Where an article comes from.
enum ArticleSource {
  /// Fetched from the public news provider.
  remote,

  /// Written inside the app by a journalist and stored in our backend.
  user,
}

/// A news article as the rest of the app sees it, regardless of its source.
///
/// Only [title], [content], [author], [category] and [publishedAt] are
/// guaranteed. [description] and [imageUrl] may be missing; the presentation
/// layer must render both cases.
class ArticleEntity extends Equatable {
  /// Average adult reading speed used for the reading-time estimate.
  static const int wordsPerMinute = 220;

  /// Stable identifier. Provider articles use their URL; own articles use the
  /// backend document id.
  final String id;
  final ArticleSource source;
  final String title;
  final String content;
  final String? description;
  final String author;
  final NewsCategory category;

  /// Identifier of the journalist who wrote the article. Only own articles
  /// have one.
  final String? authorId;

  /// Renderable image URL, when the article has a thumbnail.
  final String? imageUrl;

  /// Storage path of the thumbnail, needed to replace or delete it. Only own
  /// articles have one.
  final String? imagePath;

  /// Link to the original story. Only provider articles have one.
  final String? url;
  final DateTime publishedAt;

  const ArticleEntity({
    required this.id,
    required this.source,
    required this.title,
    required this.content,
    required this.author,
    required this.publishedAt,
    this.category = NewsCategory.general,
    this.description,
    this.authorId,
    this.imageUrl,
    this.imagePath,
    this.url,
  });

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get isUserArticle => source == ArticleSource.user;

  /// Whether the given user wrote this article.
  bool isOwnedBy(String? userId) {
    return userId != null && authorId != null && authorId == userId;
  }

  /// Estimated minutes to read the body, never less than one.
  int get readingTimeMinutes {
    final words = content.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final minutes = (words.length / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  ArticleEntity copyWith({
    String? id,
    ArticleSource? source,
    String? title,
    String? content,
    String? description,
    String? author,
    NewsCategory? category,
    String? authorId,
    String? imageUrl,
    String? imagePath,
    String? url,
    DateTime? publishedAt,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      source: source ?? this.source,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      author: author ?? this.author,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        source,
        title,
        content,
        description,
        author,
        category,
        authorId,
        imageUrl,
        imagePath,
        url,
        publishedAt,
      ];
}
