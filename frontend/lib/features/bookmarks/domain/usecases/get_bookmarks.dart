import '../entities/bookmark_entity.dart';
import '../repository/bookmark_repository.dart';

class WatchBookmarksUseCase {
  final BookmarkRepository _bookmarkRepository;

  const WatchBookmarksUseCase(this._bookmarkRepository);

  Stream<List<BookmarkEntity>> call() => _bookmarkRepository.watchBookmarks();
}
