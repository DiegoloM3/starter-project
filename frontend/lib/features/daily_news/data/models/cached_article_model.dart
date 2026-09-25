import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// A story from the last page of a section that loaded online, kept so the
/// feed still has something to show without a connection. One row per
/// story, keyed by section and position so the order survives.
@Entity(tableName: 'cached_article', primaryKeys: ['category', 'position'])
class CachedArticleModel extends ArticleEntity {
  /// NewsCategory.name of the section it was loaded for.
  final String category;
  final int position;

  /// When that section last loaded online, in milliseconds since epoch.
  final int savedAt;

  const CachedArticleModel({
    required this.category,
    required this.position,
    required this.savedAt,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.sourceName,
  });

  factory CachedArticleModel.fromRawData(Map<String, dynamic> row) {
    return CachedArticleModel(
      category: row['category'] as String,
      position: row['position'] as int,
      savedAt: row['savedAt'] as int,
      author: row['author'] as String?,
      title: row['title'] as String?,
      description: row['description'] as String?,
      url: row['url'] as String?,
      urlToImage: row['urlToImage'] as String?,
      publishedAt: row['publishedAt'] as String?,
      content: row['content'] as String?,
      sourceName: row['sourceName'] as String?,
    );
  }

  factory CachedArticleModel.fromEntity(
    ArticleEntity article, {
    required String category,
    required int position,
    required int savedAt,
  }) {
    return CachedArticleModel(
      category: category,
      position: position,
      savedAt: savedAt,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content,
      sourceName: article.sourceName,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
      sourceName: sourceName,
    );
  }
}
