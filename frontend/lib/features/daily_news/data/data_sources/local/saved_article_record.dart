import 'package:floor/floor.dart';

import '../../models/article.dart';

/// Row of the local `article` table where saved articles are stored. Keeping
/// the database mapping here leaves [ArticleModel] free of the database
/// package (rule 1.2.4).
@Entity(tableName: 'article', primaryKeys: ['id'])
class SavedArticleRecord {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const SavedArticleRecord({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory SavedArticleRecord.fromModel(ArticleModel model) {
    return SavedArticleRecord(
      id: model.id,
      author: model.author,
      title: model.title,
      description: model.description,
      url: model.url,
      urlToImage: model.urlToImage,
      publishedAt: model.publishedAt,
      content: model.content,
    );
  }

  ArticleModel toModel() {
    return ArticleModel(
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
