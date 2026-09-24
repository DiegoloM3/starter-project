import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  final String? articleType;
  final String? uploadedBy;
  final String? uploadedAt;
  final String? thumbnailURL;
  final bool? isPublished;
  final String? category;
  final int? views;

  const ArticleModel({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    this.articleType = 'api',
    this.uploadedBy,
    this.uploadedAt,
    this.thumbnailURL,
    this.isPublished = true,
    this.category,
    this.views = 0,
  }) : super(
    id: id,
    author: author,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
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

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] is int ? map['id'] : null,
      title: map['title'] ?? "",
      content: map['content'] ?? "",
      author: map['author'] ?? "",
      description: map['description'],
      url: map['url'],
      urlToImage: map['urlToImage'] ?? kDefaultImage,
      publishedAt: map['publishedAt'],
      articleType: map['articleType'] ?? 'api',
      uploadedBy: map['uploadedBy'],
      uploadedAt: map['uploadedAt'],
      thumbnailURL: map['thumbnailURL'],
      isPublished: map['isPublished'] ?? true,
      category: map['category'],
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'articleType': articleType,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'thumbnailURL': thumbnailURL,
      'isPublished': isPublished,
      'category': category,
      'views': views,
    };
  }
}