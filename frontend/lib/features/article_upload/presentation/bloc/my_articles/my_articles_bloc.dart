import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_my_articles.dart';
import 'my_articles_event.dart';
import 'my_articles_state.dart';

class MyArticlesBloc extends Bloc<MyArticlesEvent, MyArticlesState> {
  final WatchMyArticlesUseCase _watchMyArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final WatchDraftsUseCase _watchDraftsUseCase;
  final DeleteDraftUseCase _deleteDraftUseCase;

  StreamSubscription<List<JournalistArticleEntity>>? _articlesSub;
  StreamSubscription<List<DraftArticleEntity>>? _draftsSub;

  MyArticlesBloc(
    this._watchMyArticlesUseCase,
    this._deleteArticleUseCase,
    this._watchDraftsUseCase,
    this._deleteDraftUseCase,
  ) : super(const MyArticlesState()) {
    on<LoadMyArticlesEvent>(_onLoad);
    on<DeleteArticleRequestedEvent>(_onDeleteRequested);
    on<MyArticlesUpdatedEvent>((e, emit) => emit(state.copyWith(
          articles: e.articles.cast<JournalistArticleEntity>(),
          isLoading: false,
        )));
    on<MyArticlesFailedEvent>((e, emit) => emit(state.copyWith(
          isLoading: false,
          error: e.error,
        )));
    on<LoadDraftsEvent>(_onLoadDrafts);
    on<DraftsUpdatedEvent>((e, emit) => emit(state.copyWith(drafts: e.drafts)));
    on<DraftsFailedEvent>((e, emit) => emit(state.copyWith(error: e.error)));
    on<DeleteDraftRequestedEvent>(_onDeleteDraft);
  }

  Future<void> _onLoad(
    LoadMyArticlesEvent event,
    Emitter<MyArticlesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    _articlesSub?.cancel();
    _articlesSub =
        _watchMyArticlesUseCase.call(params: event.userId).listen(
      (articles) => add(MyArticlesUpdatedEvent(articles)),
      onError: (Object e, StackTrace st) =>
          add(MyArticlesFailedEvent(_mapStreamError(e, st))),
    );
  }

  Future<void> _onLoadDrafts(
    LoadDraftsEvent event,
    Emitter<MyArticlesState> emit,
  ) async {
    _draftsSub?.cancel();
    _draftsSub = _watchDraftsUseCase.call(params: null).listen(
      (drafts) => add(DraftsUpdatedEvent(drafts)),
      onError: (Object e, StackTrace st) =>
          add(DraftsFailedEvent(_mapStreamError(e, st))),
    );
  }

  AppException _mapStreamError(Object e, StackTrace st) {
    if (e is AppException) return e;
    return FirestoreException(
      message: e.toString(),
      cause: e,
      stackTrace: st,
    );
  }

  Future<void> _onDeleteRequested(
    DeleteArticleRequestedEvent event,
    Emitter<MyArticlesState> emit,
  ) async {
    final prevState = state;

    final newPending = {...state.pendingDeletes, event.articleId};
    final optimisticArticles =
        state.articles.where((a) => a.id != event.articleId).toList();

    emit(state.copyWith(pendingDeletes: newPending));

    final result = await _deleteArticleUseCase.call(
      params: DeleteArticleParams(articleId: event.articleId),
    );

    if (result is DataSuccess) {
      final clearedPending = {...state.pendingDeletes}..remove(event.articleId);
      emit(state.copyWith(
        articles: optimisticArticles,
        pendingDeletes: clearedPending,
        error: null,
      ));
    } else if (result is DataFailed) {
      emit(prevState.copyWith(
        pendingDeletes: const {},
        error: result.error,
      ));
    }
  }

  Future<void> _onDeleteDraft(
    DeleteDraftRequestedEvent event,
    Emitter<MyArticlesState> emit,
  ) async {
    final prevState = state;
    final optimisticDrafts =
        state.drafts.where((d) => d.id != event.draftId).toList();

    emit(state.copyWith(drafts: optimisticDrafts));

    final result = await _deleteDraftUseCase.call(
      params: DraftIdParams(draftId: event.draftId),
    );

    if (result is DataFailed) {
      emit(prevState.copyWith(error: result.error));
    }
  }

  @override
  Future<void> close() {
    _articlesSub?.cancel();
    _draftsSub?.cancel();
    return super.close();
  }
}
