import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// A news article as NewsAPI sends it, or as it is saved on the phone.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    super.id,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
  });

  /// Parses an article from the NewsAPI response.
  factory ArticleModel.fromRawData(Map<String, dynamic> rawData) {
    return ArticleModel(
      author: rawData['author'] ?? '',
      title: rawData['title'] ?? '',
      description: rawData['description'] ?? '',
      url: rawData['url'] ?? '',
      // Without an image the app shows a placeholder.
      urlToImage: rawData['urlToImage'] ?? '',
      publishedAt: rawData['publishedAt'] ?? '',
      content: rawData['content'] ?? '',
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
    );
  }
}
