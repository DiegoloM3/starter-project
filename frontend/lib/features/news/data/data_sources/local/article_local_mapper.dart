import 'package:drift/drift.dart' show Value;
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';

/// Drift persistence mapping for [ArticleModel].
///
/// Lives in the data-source layer so models never import database
/// providers (1.2.4); repositories translate through these helpers.
class ArticleLocalMapper {
  /// Builds a model from a Drift [row], defaulting missing images.
  static ArticleModel fromRow(ArticlesTableData row) {
    return ArticleModel(
      id: row.id,
      authorDisplayName: row.authorDisplayName,
      title: row.title,
      urlToImage: row.urlToImage ?? kDefaultImage,
      publishedAt: row.publishedAt,
      content: row.content,
      authorId: row.authorId,
    );
  }

  /// Converts a [model] to a Drift companion for insert/update operations.
  static ArticlesTableCompanion toCompanion(ArticleModel model) {
    return ArticlesTableCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      authorDisplayName: Value(model.authorDisplayName),
      title: Value(model.title),
      urlToImage: Value(model.urlToImage),
      publishedAt: Value(model.publishedAt),
      content: Value(model.content),
      authorId: Value(model.authorId),
    );
  }
}
