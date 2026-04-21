import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';

sealed class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentEntity> comments;
  final bool submitting;
  final String? submitError;

  const CommentsLoaded({
    required this.comments,
    this.submitting = false,
    this.submitError,
  });

  CommentsLoaded copyWith({
    List<CommentEntity>? comments,
    bool? submitting,
    String? submitError,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      submitting: submitting ?? this.submitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [comments, submitting, submitError];
}

class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}
