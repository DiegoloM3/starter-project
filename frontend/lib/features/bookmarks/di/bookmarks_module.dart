import 'package:injectable/injectable.dart';

import '../domain/repository/bookmark_repository.dart';
import '../domain/usecases/add_bookmark.dart';
import '../domain/usecases/get_bookmarks.dart';
import '../domain/usecases/is_bookmarked.dart';
import '../domain/usecases/remove_bookmark.dart';

@module
abstract class BookmarksModule {
  @lazySingleton
  WatchBookmarksUseCase watchBookmarksUseCase(BookmarkRepository repository) =>
      WatchBookmarksUseCase(repository);

  @lazySingleton
  AddBookmarkUseCase addBookmarkUseCase(BookmarkRepository repository) =>
      AddBookmarkUseCase(repository);

  @lazySingleton
  RemoveBookmarkUseCase removeBookmarkUseCase(BookmarkRepository repository) =>
      RemoveBookmarkUseCase(repository);

  @lazySingleton
  IsBookmarkedUseCase isBookmarkedUseCase(BookmarkRepository repository) =>
      IsBookmarkedUseCase(repository);
}
