import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    String? id,
    String? authorName,
    String? title,
    String? description,
    String? url,
    String? thumbnailUrl,
    String? publishedAt,
    String? content,
    String? authorId,
    String? thumbnailPath,
    String? createdAt,
    String? updatedAt,
    String? status,
    bool? isDeleted,
    int? readingTimeMinutes,
  }) : super(
    id: id,
    authorName: authorName,
    title: title,
    description: description,
    url: url,
    thumbnailUrl: thumbnailUrl,
    publishedAt: publishedAt,
    content: content,
    authorId: authorId,
    thumbnailPath: thumbnailPath,
    createdAt: createdAt,
    updatedAt: updatedAt,
    status: status,
    isDeleted: isDeleted,
    readingTimeMinutes: readingTimeMinutes,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      authorName: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      thumbnailUrl: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  factory ArticleModel.fromRawData(Map<String, dynamic> map) =>
      ArticleModel.fromJson(map);

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      authorName: entity.authorName,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      publishedAt: entity.publishedAt,
      content: entity.content,
      authorId: entity.authorId,
      thumbnailPath: entity.thumbnailPath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      isDeleted: entity.isDeleted,
      readingTimeMinutes: entity.readingTimeMinutes,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      authorName: authorName,
      title: title,
      description: description,
      url: url,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      content: content,
      authorId: authorId,
      thumbnailPath: thumbnailPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      isDeleted: isDeleted,
      readingTimeMinutes: readingTimeMinutes,
    );
  }
}