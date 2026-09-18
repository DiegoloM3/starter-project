import '../entities/article_thumbnail.dart';

class PublishArticleParams {
  final String author;
  final String title;
  final String description;
  final String content;
  final ArticleThumbnail thumbnail;

  const PublishArticleParams({
    required this.author,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnail,
  });
}
