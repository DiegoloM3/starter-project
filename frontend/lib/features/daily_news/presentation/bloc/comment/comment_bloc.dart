import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_comments.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  StreamSubscription<DataState<List<CommentEntity>>>? _subscription;

  CommentBloc(
    this._getCommentsUseCase,
    this._addCommentUseCase,
    this._deleteCommentUseCase,
  ) : super(const CommentsLoading()) {
    on<CommentsSubscriptionRequested>(_onSubscriptionRequested);
    on<CommentsUpdated>(_onUpdated);
    on<CommentAdded>(_onCommentAdded);
    on<CommentDeleted>(_onCommentDeleted);
  }

  void _onSubscriptionRequested(
    CommentsSubscriptionRequested event,
    Emitter<CommentState> emit,
  ) {
    emit(const CommentsLoading());
    _subscription?.cancel();
    _subscription =
        _getCommentsUseCase(params: event.articleId).listen(
      (dataState) => add(CommentsUpdated(dataState)),
    );
  }

  void _onUpdated(
    CommentsUpdated event,
    Emitter<CommentState> emit,
  ) {
    if (event.dataState is DataSuccess) {
      emit(CommentsDone(event.dataState.data!));
    }
    if (event.dataState is DataFailed) {
      emit(CommentsFailure(event.dataState.error!));
    }
  }

  Future<void> _onCommentAdded(
    CommentAdded event,
    Emitter<CommentState> emit,
  ) async {
    final result =
        await _addCommentUseCase(params: event.comment);

    if (result is DataFailed) {
      emit(CommentsFailure(result.error!));
    }
  }

  Future<void> _onCommentDeleted(
    CommentDeleted event,
    Emitter<CommentState> emit,
  ) async {
    final result = await _deleteCommentUseCase(
      params: DeleteCommentParams(
        articleId: event.articleId,
        commentId: event.commentId,
      ),
    );

    if (result is DataFailed) {
      emit(CommentsFailure(result.error!));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
