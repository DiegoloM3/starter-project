part of 'comments_bloc.dart';

/// Events consumed by [CommentsBloc].
abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentsEvent {
  final String articleId;

  const LoadComments(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class PostCommentRequested extends CommentsEvent {
  final String articleId;
  final String content;

  const PostCommentRequested({
    required this.articleId,
    required this.content,
  });

  @override
  List<Object?> get props => [articleId, content];
}

class DeleteCommentRequested extends CommentsEvent {
  final String articleId;
  final String commentId;

  const DeleteCommentRequested({
    required this.articleId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [articleId, commentId];
}

class ResetComments extends CommentsEvent {
  const ResetComments();
}
