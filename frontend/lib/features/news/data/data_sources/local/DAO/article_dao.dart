import 'package:drift/drift.dart';

import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';

part 'article_dao.g.dart';

/// DAO for cached articles in the local database.
@DriftAccessor(tables: [ArticlesTable])
class ArticleDao extends DatabaseAccessor<AppDatabase>
    with _$ArticleDaoMixin {
  ArticleDao(super.db);

  /// Returns all locally stored article rows.
  Future<List<ArticlesTableData>> getArticles() => select(articlesTable).get();

  /// Inserts or replaces [article] in local storage.
  Future<void> insertArticle(ArticlesTableCompanion article) =>
      into(articlesTable).insert(article, mode: InsertMode.insertOrReplace);

  /// Deletes rows identical to [article], NULL-safely: legacy rows saved
  /// before API articles carried ids have NULL `id`, where `= NULL` never
  /// matches and `article.id!` throws (the Saved-page delete crash).
  Future<void> deleteArticle(ArticlesTableData article) {
    return (delete(articlesTable)..where((t) {
      var predicate = _matches(t.id, article.id);
      predicate &= _matches(t.authorDisplayName, article.authorDisplayName);
      predicate &= _matches(t.title, article.title);
      predicate &= _matches(t.urlToImage, article.urlToImage);
      predicate &= _matches(t.publishedAt, article.publishedAt);
      predicate &= _matches(t.content, article.content);
      predicate &= _matches(t.authorId, article.authorId);
      return predicate;
    })).go();
  }

  Expression<bool> _matches(
    GeneratedColumn<String> column,
    String? value,
  ) {
    return value == null ? column.isNull() : column.equals(value);
  }
}
