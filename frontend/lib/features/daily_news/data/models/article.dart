import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    double? tokensEarned,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
          tokensEarned: tokensEarned,
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
      tokensEarned: (map['tokensEarned'] as num?)?.toDouble() ?? 0.0,
    );

  }

  factory ArticleModel.fromRawData(Map<String, dynamic> map) => ArticleModel.fromJson(map);

  ArticleEntity toEntity() => ArticleEntity(
        id: id,
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt,
        content: content,
        tokensEarned: tokensEarned,
      );


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
        tokensEarned: entity.tokensEarned);
  }


  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'author': author ?? "",
      'title': title ?? "",
      'description': description ?? "",
      'url': url ?? "",
      'urlToImage': urlToImage ?? "",
      'publishedAt': publishedAt ?? "",
      'content': content ?? "",
      'source': 'Symmetry Journalist',
      'category': 'general',
      'views': 0,
      'readTime': 0,
      'tokensEarned': tokensEarned ?? 0.0,
    };

  }

  Map<String, dynamic> toRawData() => toJson();

  String get articleId {
    if (url != null && url!.isNotEmpty) {
      return url!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    }
    return (title ?? "unknown").replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
  }
}