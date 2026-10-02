import 'package:floor/floor.dart';

import '../../models/article.dart';

/// A news article saved on the phone: a row of the `article` table of the app's database.
///
/// Floor needs an annotated class for each table. It lives here, with the database, because the data sources
/// are the only place that imports a provider (docs/ARCHITECTURE_VIOLATIONS.md, 1.2.4); the model stays free
/// of Floor. The table is the same one the app has always used, so saved articles are kept.
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

  factory SavedArticleRecord.fromModel(ArticleModel article) {
    return SavedArticleRecord(
      id: article.id,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content,
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
