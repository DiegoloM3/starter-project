import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';

abstract class ArticleCommentsState extends Equatable {
  const ArticleCommentsState();

  @override
  List<Object?> get props => [];
}

class ArticleCommentsInProgress extends ArticleCommentsState {
  const ArticleCommentsInProgress();
}

class ArticleCommentsSuccess extends ArticleCommentsState {
  final List<ArticleCommentEntity> comments;

  const ArticleCommentsSuccess(this.comments);

  @override
  List<Object?> get props => [comments];
}

class ArticleCommentsFailure extends ArticleCommentsState {
  final Exception error;

  const ArticleCommentsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
