import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
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

  factory ArticleModel.fromRawData(Map<String, dynamic> raw) {
    return ArticleModel(
      author: raw['author'] ?? '',
      title: raw['title'] ?? '',
      description: raw['description'] ?? '',
      url: raw['url'] ?? '',
      urlToImage: raw['urlToImage'] != null && raw['urlToImage'] != ''
          ? raw['urlToImage']
          : kDefaultImage,
      publishedAt: raw['publishedAt'] ?? '',
      content: raw['content'] ?? '',
    );
  }

  // Retrofit/Floor generated code calls `fromJson`; keep it as an alias.
  factory ArticleModel.fromJson(Map<String, dynamic> map) =>
      ArticleModel.fromRawData(map);

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

  ArticleEntity toEntity() => ArticleEntity(
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
