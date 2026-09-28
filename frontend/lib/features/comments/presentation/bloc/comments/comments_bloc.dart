import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';

part 'comments_event.dart';
part 'comments_state.dart';

@injectable
/// UI state machine for loading, posting, and deleting comments.
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetArticleComments _getArticleComments;
  final PostComment _postComment;
  final DeleteComment _deleteComment;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  CommentsBloc(
    this._getArticleComments,
    this._postComment,
    this._deleteComment,
    this._getCurrentUserUseCase,
  ) : super(const CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<PostCommentRequested>(_onPostCommentRequested);
    on<DeleteCommentRequested>(_onDeleteCommentRequested);
    on<ResetComments>(_onReset);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(const CommentsLoading());
    await _emitLoaded(event.articleId, emit);
  }

  Future<void> _onPostCommentRequested(
    PostCommentRequested event,
    Emitter<CommentsState> emit,
  ) async {
    if (event.content.trim().isEmpty) {
      emit(const CommentsError('Comment cannot be empty.'));
      return;
    }

    final author = await _currentUser();
    if (author == null) {
      emit(const CommentsError('Please log in to comment.'));
      return;
    }

    final result = await _postComment(
      params: PostCommentParams(
        comment: CommentEntity(
          articleId: event.articleId,
          authorId: author.id,
          authorDisplayName: author.displayName,
          content: event.content.trim(),
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
    );

    if (result is DataSuccess) {
      await _emitLoaded(event.articleId, emit);
    } else {
      emit(CommentsError(_failureMessage(result)));
    }
  }

  Future<void> _onDeleteCommentRequested(
    DeleteCommentRequested event,
    Emitter<CommentsState> emit,
  ) async {
    final userId = await _currentUserId();
    if (userId == null) {
      emit(const CommentsError('Please log in to delete your comment.'));
      return;
    }

    final result = await _deleteComment(
      params: DeleteCommentParams(commentId: event.commentId),
    );

    if (result is DataSuccess) {
      await _emitLoaded(event.articleId, emit);
    } else {
      emit(CommentsError(_failureMessage(result)));
    }
  }

  /// Reloads the comment list and emits it alongside the viewer id, so
  /// guests see the list while only owners see delete actions.
  Future<void> _emitLoaded(
    String articleId,
    Emitter<CommentsState> emit,
  ) async {
    final userId = await _currentUserId();
    final result = await _getArticleComments(
      params: GetArticleCommentsParams(articleId: articleId),
    );

    if (result is DataSuccess) {
      emit(CommentsLoaded(
        comments: result.data ?? const [],
        currentUserId: userId,
      ));
    } else {
      emit(CommentsError(_failureMessage(result)));
    }
  }

  Future<_CommentAuthor?> _currentUser() async {
    final user = await _getCurrentUserUseCase();
    if (user is! DataSuccess || user.data == null) return null;
    return _CommentAuthor(
      id: user.data!.id,
      displayName: user.data!.displayName ?? 'Anonymous',
    );
  }

  Future<String?> _currentUserId() async {
    final author = await _currentUser();
    return author?.id;
  }

  String _failureMessage(DataState result) {
    return result.errorMessage ?? result.error?.toString() ?? 'Unknown error.';
  }

  void _onReset(ResetComments event, Emitter<CommentsState> emit) {
    emit(const CommentsInitial());
  }
}

class _CommentAuthor {
  final String id;
  final String displayName;

  const _CommentAuthor({required this.id, required this.displayName});
}
