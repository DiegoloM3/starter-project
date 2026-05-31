import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/community_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/watch_community_articles.dart';

import 'community_articles_event.dart';
import 'community_articles_state.dart';

class CommunityArticlesBloc
    extends Bloc<CommunityArticlesEvent, CommunityArticlesState> {
  CommunityArticlesBloc(
    this._getCommunityArticles,
    this._watchCommunityArticles,
  ) : super(const CommunityArticlesState()) {
    on<CommunityArticlesRequested>(_onRequested);
    on<CommunityArticlesRefreshRequested>(_onRefreshRequested);
    on<CommunityArticlesNextPageRequested>(_onNextPageRequested);
    on<CommunityArticlesStreamUpdated>(_onStreamUpdated);
    on<CommunityArticlesStreamFailed>(_onStreamFailed);
  }

  final GetCommunityArticlesUseCase _getCommunityArticles;
  final WatchCommunityArticlesUseCase _watchCommunityArticles;
  StreamSubscription<DataState<List<CommunityArticleEntity>>>?
  _articlesSubscription;

  Future<void> _onRequested(
    CommunityArticlesRequested event,
    Emitter<CommunityArticlesState> emit,
  ) async {
    await _watchFirstPage(emit);
  }

  Future<void> _onRefreshRequested(
    CommunityArticlesRefreshRequested event,
    Emitter<CommunityArticlesState> emit,
  ) async {
    await _watchFirstPage(emit);
  }

  Future<void> _watchFirstPage(Emitter<CommunityArticlesState> emit) async {
    emit(
      state.copyWith(
        status: CommunityArticlesStatus.loading,
        articles: const [],
        hasMore: true,
        isLoadingMore: false,
        clearFailure: true,
      ),
    );

    await _articlesSubscription?.cancel();
    _articlesSubscription =
        _watchCommunityArticles(params: const CommunityArticleParams()).listen((
          result,
        ) {
          switch (result) {
            case DataSuccess<dynamic>(:final data):
              add(CommunityArticlesStreamUpdated(data));
            case DataFailed<dynamic>(:final failure):
              add(CommunityArticlesStreamFailed(failure));
          }
        });
  }

  void _onStreamUpdated(
    CommunityArticlesStreamUpdated event,
    Emitter<CommunityArticlesState> emit,
  ) {
    emit(
      state.copyWith(
        status: CommunityArticlesStatus.success,
        articles: event.articles,
        hasMore:
            event.articles.length >= const CommunityArticleParams().pageSize,
        isLoadingMore: false,
        clearFailure: true,
      ),
    );
  }

  void _onStreamFailed(
    CommunityArticlesStreamFailed event,
    Emitter<CommunityArticlesState> emit,
  ) {
    emit(
      state.copyWith(
        status: CommunityArticlesStatus.failure,
        failure: event.failure,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> _onNextPageRequested(
    CommunityArticlesNextPageRequested event,
    Emitter<CommunityArticlesState> emit,
  ) async {
    if (state.status != CommunityArticlesStatus.success ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.articles.isEmpty) {
      return;
    }

    final existingArticles = state.articles;
    emit(state.copyWith(isLoadingMore: true, clearFailure: true));

    final result = await _getCommunityArticles(
      params: CommunityArticleParams(lastDocumentId: existingArticles.last.id),
    );

    switch (result) {
      case DataSuccess<dynamic>(:final data):
        emit(
          state.copyWith(
            status: CommunityArticlesStatus.success,
            articles: <CommunityArticleEntity>[
              ...existingArticles,
              ...data.articles,
            ],
            hasMore: data.hasMore,
            isLoadingMore: false,
            clearFailure: true,
          ),
        );
      case DataFailed<dynamic>():
        emit(state.copyWith(isLoadingMore: false));
    }
  }

  @override
  Future<void> close() async {
    await _articlesSubscription?.cancel();
    _articlesSubscription = null;
    return super.close();
  }
}
