import 'package:equatable/equatable.dart';

import '../../../domain/entities/comment.dart';
import '../../../domain/params/add_comment_params.dart';

enum CommentsStatus { initial, loading, success, failure }

enum CommentsAction { add, delete }

class CommentsState extends Equatable {
  final CommentsStatus status;

  /// Newest first.
  final List<CommentEntity> comments;

  final bool isSending;
  final Set<CommentValidationError> validationErrors;

  /// The last action that failed for an unexpected reason, so the screen can report it.
  final CommentsAction? failedAction;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.isSending = false,
    this.validationErrors = const {},
    this.failedAction,
  });

  @override
  List<Object?> get props => [status, comments, isSending, validationErrors, failedAction];
}
