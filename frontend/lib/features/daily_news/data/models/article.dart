import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article',primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int ? id,
    String? documentId,
    String? authorId,
    String ? author,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
  }): super(
    id: id,
    documentId: documentId,
    authorId: authorId,
    author: author,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
  );

  factory ArticleModel.fromJson(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final dynamic rawImage = map['urlToImage'] ?? map['thumbnailURL'];
    final String imageValue = (rawImage is String && rawImage.isNotEmpty)
        ? rawImage
        : kDefaultImage;

    final dynamic rawPublishedAt = map['publishedAt'];
    final String publishedAtValue = rawPublishedAt is Timestamp
        ? rawPublishedAt.toDate().toIso8601String()
        : (rawPublishedAt?.toString() ?? "");

    return ArticleModel(
      documentId: documentId,
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: imageValue,
      publishedAt: publishedAtValue,
      content: map['content'] ?? "",
      authorId: map['authorId'] ?? "",
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      documentId: entity.documentId,
      authorId: entity.authorId,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content
    );
  }
}
