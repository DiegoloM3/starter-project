import '../entities/article_source.dart';
import '../entities/bookmark_entity.dart';

/// Parameters for [AddBookmarkUseCase].
class BookmarkParams {
  final BookmarkEntity bookmark;

  const BookmarkParams({required this.bookmark});
}

/// Parameters for [RemoveBookmarkUseCase] and [IsBookmarkedUseCase].
class BookmarkIdentifierParams {
  final String sourceId;
  final ArticleSource source;

  const BookmarkIdentifierParams({
    required this.sourceId,
    required this.source,
  });
}
