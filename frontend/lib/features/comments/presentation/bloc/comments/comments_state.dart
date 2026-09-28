part of 'comments_bloc.dart';

/// UI states emitted by [CommentsBloc].
abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentEntity> comments;

  /// Null when the viewer is a guest: the list still renders, but the
  /// composer is replaced by a login prompt and delete stays hidden.
  final String? currentUserId;

  const CommentsLoaded({
    required this.comments,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [comments, currentUserId];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}
