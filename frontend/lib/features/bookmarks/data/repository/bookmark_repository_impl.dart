import 'package:injectable/injectable.dart';

import '../../domain/entities/article_source.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../../domain/repository/bookmark_repository.dart';
import '../datasources/local/local_bookmarks_datasource.dart';
import '../models/bookmark_model.dart';

@LazySingleton(as: BookmarkRepository)
class BookmarkRepositoryImpl implements BookmarkRepository {
  final LocalBookmarksDataSource _localDataSource;

  const BookmarkRepositoryImpl(this._localDataSource);

  @override
  Stream<List<BookmarkEntity>> watchBookmarks() {
    return _localDataSource.watchBookmarks().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> addBookmark(BookmarkEntity bookmark) {
    return _localDataSource.addBookmark(BookmarkModel.fromEntity(bookmark));
  }

  @override
  Future<void> removeBookmark(String sourceId, ArticleSource source) {
    return _localDataSource.removeBookmark(sourceId, source);
  }

  @override
  Future<bool> isBookmarked(String sourceId, ArticleSource source) {
    return _localDataSource.isBookmarked(sourceId, source);
  }
}
