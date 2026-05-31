import 'package:equatable/equatable.dart';

import '../../domain/entities/bookmark_entity.dart';

sealed class BookmarkState extends Equatable {
  const BookmarkState();
}

final class BookmarksLoading extends BookmarkState {
  const BookmarksLoading();

  @override
  List<Object?> get props => [];
}

final class BookmarksDone extends BookmarkState {
  final List<BookmarkEntity> bookmarks;

  const BookmarksDone(this.bookmarks);

  @override
  List<Object?> get props => [bookmarks];
}
