import '../entities/article_image.dart';

class PublishArticleParams {
  final String clientId;
  final String title;
  final String content;
  final ArticleImageEntity? image;

  const PublishArticleParams({
    required this.clientId,
    required this.title,
    required this.content,
    this.image,
  });
}
