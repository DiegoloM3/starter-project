import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../domain/entities/comment.dart';

abstract class CommentState extends Equatable {
  final List<CommentEntity>? comments;
  final AppException? error;

  const CommentState({this.comments, this.error});

  @override
  List<Object?> get props => [comments, error];
}

class CommentsLoading extends CommentState {
  const CommentsLoading();
}

class CommentsDone extends CommentState {
  const CommentsDone(List<CommentEntity> comments)
      : super(comments: comments);
}

/// The comment stream failed to load. Replaces the list with an error UI.
class CommentsLoadFailure extends CommentState {
  const CommentsLoadFailure(AppException error) : super(error: error);
}

/// An add/delete action failed. Carries the current comments so the list stays
/// visible while a snackbar surfaces the error.
class CommentsActionFailure extends CommentState {
  const CommentsActionFailure(
    AppException error, {
    required List<CommentEntity> comments,
  }) : super(comments: comments, error: error);
}
