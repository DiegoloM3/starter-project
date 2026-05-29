import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
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
      onError: (Object error) {
        add(CommentsUpdated(DataFailed(
          AppException(message: error.toString(), code: 'stream_error'),
        )));
      },
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
      emit(CommentsLoadFailure(event.dataState.error!));
    }
  }

  Future<void> _onCommentAdded(
    CommentAdded event,
    Emitter<CommentState> emit,
  ) async {
    final result =
        await _addCommentUseCase(params: event.comment);

    // On success the realtime stream re-emits CommentsDone with the new comment,
    // so no success state is needed here. On failure keep the current list and
    // surface the error as a transient action failure.
    if (result is DataFailed) {
      emit(CommentsActionFailure(
        result.error!,
        comments: state.comments ?? const [],
      ));
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
      emit(CommentsActionFailure(
        result.error!,
        comments: state.comments ?? const [],
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
