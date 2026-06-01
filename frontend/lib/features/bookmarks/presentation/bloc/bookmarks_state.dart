import 'package:equatable/equatable.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

abstract class BookmarksState extends Equatable {
  const BookmarksState();

  @override
  List<Object> get props => [];
}

class BookmarksInitial extends BookmarksState {
  const BookmarksInitial();
}

class BookmarksLoading extends BookmarksState {
  const BookmarksLoading();
}

class BookmarksEmpty extends BookmarksState {
  const BookmarksEmpty();
}

class BookmarksLoaded extends BookmarksState {
  final List<ArticleEntity> articles;
  final bool hasMore;

  const BookmarksLoaded({required this.articles, required this.hasMore});

  @override
  List<Object> get props => [articles, hasMore];
}

class BookmarksError extends BookmarksState {
  final String message;

  const BookmarksError(this.message);

  @override
  List<Object> get props => [message];
}
