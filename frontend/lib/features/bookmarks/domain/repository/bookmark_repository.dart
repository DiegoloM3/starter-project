import '../entities/article_source.dart';
import '../entities/bookmark_entity.dart';

abstract class BookmarkRepository {
  Stream<List<BookmarkEntity>> watchBookmarks();

  Future<void> addBookmark(BookmarkEntity bookmark);

  Future<void> removeBookmark(String sourceId, ArticleSource source);

  Future<bool> isBookmarked(String sourceId, ArticleSource source);
}
