import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';

import '../../../domain/entities/article_source.dart';
import '../../models/bookmark_model.dart';
import 'app_database.dart';

/// Data source that wraps [BookmarkDao] with exception handling.
///
/// This is the only class that directly accesses the local Drift database
/// for bookmarks. Throws [CacheException] on any database failure.
@lazySingleton
class LocalBookmarksDataSource {
  final AppDatabase _database;

  LocalBookmarksDataSource(this._database);

  Future<List<BookmarkModel>> getBookmarks() async {
    try {
      return await _database.bookmarkDao.getAllBookmarks();
    } catch (_) {
      throw const CacheException(CacheErrorKeys.generic);
    }
  }

  Stream<List<BookmarkModel>> watchBookmarks() {
    try {
      return _database.bookmarkDao.watchAllBookmarks();
    } catch (_) {
      throw const CacheException(CacheErrorKeys.generic);
    }
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _database.bookmarkDao.insertBookmark(bookmark);
    } catch (_) {
      throw const CacheException(CacheErrorKeys.writeError);
    }
  }

  Future<void> removeBookmark(String sourceId, ArticleSource source) async {
    try {
      await _database.bookmarkDao.deleteBookmark(sourceId, source.name);
    } catch (_) {
      throw const CacheException(CacheErrorKeys.writeError);
    }
  }

  Future<bool> isBookmarked(String sourceId, ArticleSource source) async {
    try {
      final result = await _database.bookmarkDao.findBookmark(
        sourceId,
        source.name,
      );
      return result != null;
    } catch (_) {
      throw const CacheException(CacheErrorKeys.generic);
    }
  }
}
