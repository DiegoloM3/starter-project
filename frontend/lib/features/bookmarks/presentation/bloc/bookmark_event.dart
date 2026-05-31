import 'package:equatable/equatable.dart';

import '../../domain/entities/article_source.dart';
import '../../domain/entities/bookmark_entity.dart';

sealed class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

final class GetBookmarksEvent extends BookmarkEvent {
  const GetBookmarksEvent();
}

final class AddBookmarkEvent extends BookmarkEvent {
  final BookmarkEntity bookmark;

  const AddBookmarkEvent(this.bookmark);

  @override
  List<Object?> get props => [bookmark];
}

final class RemoveBookmarkEvent extends BookmarkEvent {
  final String sourceId;
  final ArticleSource source;

  const RemoveBookmarkEvent(this.sourceId, this.source);

  @override
  List<Object?> get props => [sourceId, source];
}

final class BookmarksUpdatedEvent extends BookmarkEvent {
  final List<BookmarkEntity> bookmarks;

  const BookmarksUpdatedEvent(this.bookmarks);

  @override
  List<Object?> get props => [bookmarks];
}
