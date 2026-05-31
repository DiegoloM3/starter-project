import 'package:drift/drift.dart';

import '../../../../domain/entities/article_source.dart';
import '../../../models/bookmark_model.dart';
import '../app_database.dart';
import '../tables/bookmarks_table.dart';

part 'bookmark_dao.g.dart';

@DriftAccessor(tables: [Bookmarks])
class BookmarkDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarkDaoMixin {
  BookmarkDao(super.db);

  Future<void> insertBookmark(BookmarkModel bookmark) {
    return into(bookmarks).insertOnConflictUpdate(
      BookmarksCompanion(
        sourceId: Value(bookmark.sourceId),
        source: Value(bookmark.source.name),
        title: Value(bookmark.title),
        description: Value(bookmark.description),
        imageUrl: Value(bookmark.imageUrl),
        url: Value(bookmark.url),
        author: Value(bookmark.author),
        publishedAt: Value(bookmark.publishedAt),
        content: Value(bookmark.content),
      ),
    );
  }

  Future<void> deleteBookmark(String sourceId, String source) {
    return (delete(bookmarks)..where(
          (tbl) => tbl.sourceId.equals(sourceId) & tbl.source.equals(source),
        ))
        .go();
  }

  Future<List<BookmarkModel>> getAllBookmarks() async {
    final rows = await select(bookmarks).get();
    return rows
        .map(
          (row) => BookmarkModel(
            sourceId: row.sourceId,
            source: ArticleSource.values.firstWhere(
              (e) => e.name == row.source,
            ),
            title: row.title,
            description: row.description,
            imageUrl: row.imageUrl,
            url: row.url,
            author: row.author,
            publishedAt: row.publishedAt,
            content: row.content,
          ),
        )
        .toList();
  }

  Stream<List<BookmarkModel>> watchAllBookmarks() {
    return select(bookmarks).watch().map(
      (rows) => rows
          .map(
            (row) => BookmarkModel(
              sourceId: row.sourceId,
              source: ArticleSource.values.firstWhere(
                (e) => e.name == row.source,
              ),
              title: row.title,
              description: row.description,
              imageUrl: row.imageUrl,
              url: row.url,
              author: row.author,
              publishedAt: row.publishedAt,
              content: row.content,
            ),
          )
          .toList(),
    );
  }

  Future<BookmarkModel?> findBookmark(String sourceId, String source) async {
    final row =
        await (select(bookmarks)..where(
              (tbl) =>
                  tbl.sourceId.equals(sourceId) & tbl.source.equals(source),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return BookmarkModel(
      sourceId: row.sourceId,
      source: ArticleSource.values.firstWhere((e) => e.name == row.source),
      title: row.title,
      description: row.description,
      imageUrl: row.imageUrl,
      url: row.url,
      author: row.author,
      publishedAt: row.publishedAt,
      content: row.content,
    );
  }
}
