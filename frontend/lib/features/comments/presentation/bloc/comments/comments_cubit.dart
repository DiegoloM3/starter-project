import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/exceptions/comment_exceptions.dart';
import '../../../domain/params/add_comment_params.dart';
import '../../../domain/usecases/add_comment.dart';
import '../../../domain/usecases/delete_comment.dart';
import '../../../domain/usecases/get_comments.dart';
import 'comments_state.dart';

/// Comments of one article.
class CommentsCubit extends Cubit<CommentsState> {
  final String _articleId;
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentsCubit(this._articleId, this._getCommentsUseCase, this._addCommentUseCase, this._deleteCommentUseCase)
    : super(const CommentsState());

  Future<void> load() async {
    emit(CommentsState(status: CommentsStatus.loading, comments: state.comments));
    final result = await _getCommentsUseCase(_articleId);
    if (result is DataSuccess) {
      emit(CommentsState(status: CommentsStatus.success, comments: result.data!));
    } else {
      emit(CommentsState(status: CommentsStatus.failure, comments: state.comments));
    }
  }

  /// Returns whether the comment was added, so the screen can clear the text field.
  Future<bool> add(String text) async {
    emit(CommentsState(status: state.status, comments: state.comments, isSending: true));
    final result = await _addCommentUseCase(AddCommentParams(articleId: _articleId, text: text));
    emit(_stateAfterAdding(result));
    return result is DataSuccess;
  }

  /// Hides the comment at once and shows it again if it cannot be deleted.
  Future<void> delete(CommentEntity comment) async {
    final previousComments = state.comments;
    emit(CommentsState(status: state.status, comments: previousComments.where((c) => c.id != comment.id).toList()));

    final result = await _deleteCommentUseCase(comment);
    if (result is DataFailed) {
      emit(CommentsState(status: state.status, comments: previousComments, failedAction: CommentsAction.delete));
    }
  }

  CommentsState _stateAfterAdding(DataState<CommentEntity> result) {
    return switch (result.error) {
      null => CommentsState(status: state.status, comments: [result.data!, ...state.comments]),
      CommentValidationException(:final errors) => CommentsState(
        status: state.status,
        comments: state.comments,
        validationErrors: errors,
      ),
      _ => CommentsState(status: state.status, comments: state.comments, failedAction: CommentsAction.add),
    };
  }
}
