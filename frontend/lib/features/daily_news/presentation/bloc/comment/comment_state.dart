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

class CommentsFailure extends CommentState {
  const CommentsFailure(AppException error) : super(error: error);
}
