import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/delete_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/watch_comments.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments_state.dart';

class CommentsDeps {
  final AddCommentUseCase addComment;
  final WatchCommentsUseCase watchComments;
  final DeleteCommentUseCase deleteComment;

  const CommentsDeps({
    required this.addComment,
    required this.watchComments,
    required this.deleteComment,
  });
}

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsDeps _deps;

  StreamSubscription<List<CommentEntity>>? _subscription;

  CommentsCubit(this._deps) : super(const CommentsLoading());

  void load(String articleId) {
    _subscription?.cancel();
    _subscription = _deps.watchComments(articleId).listen(
      (comments) {
        final prev = state;
        if (prev is CommentsLoaded) {
          emit(prev.copyWith(comments: comments));
        } else {
          emit(CommentsLoaded(comments: comments));
        }
      },
      onError: (err) => emit(CommentsError(err.toString())),
    );
  }

  Future<bool> submit(String articleId, String text, {String? replyTo}) async {
    final current = state;
    if (current is! CommentsLoaded) return false;
    emit(current.copyWith(submitting: true, submitError: null));
    try {
      await _deps.addComment(
        params: AddCommentParams(
          articleId: articleId,
          text: text,
          replyTo: replyTo,
        ),
      );
      final latest = state;
      if (latest is CommentsLoaded) {
        emit(latest.copyWith(submitting: false));
      }
      return true;
    } on CommentException catch (e) {
      final latest = state;
      if (latest is CommentsLoaded) {
        emit(latest.copyWith(submitting: false, submitError: e.message));
      }
      return false;
    }
  }

  Future<void> delete(String articleId, String commentId) async {
    try {
      await _deps.deleteComment(
          params: DeleteCommentParams(
        articleId: articleId,
        commentId: commentId,
      ));
    } on CommentException catch (_) {
      // Swallow: the comments stream will reconcile any inconsistent state.
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
