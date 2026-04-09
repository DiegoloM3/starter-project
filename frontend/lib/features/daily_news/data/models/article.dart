import 'package:froom/froom.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    String? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? publishedAt,
    String? content,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          publishedAt: publishedAt,
          content: content,
        );

  factory ArticleModel.fromJson({
    required Map<String, dynamic> map,
    required String id,
  }) {
    return ArticleModel(
      id: id,
      author: map['author'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      publishedAt: map['publishedAt'] ?? '',
      content: map['content'] ?? '',
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
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
        publishedAt: publishedAt,
        content: content,
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'title': title,
        'description': description,
        'url': url,
        'publishedAt': publishedAt,
        'content': content,
      };
}
