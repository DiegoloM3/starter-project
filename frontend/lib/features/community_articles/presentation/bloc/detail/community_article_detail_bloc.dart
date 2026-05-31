import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/community_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/delete_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_article_by_id.dart';

import 'community_article_detail_event.dart';
import 'community_article_detail_state.dart';

class CommunityArticleDetailBloc
    extends Bloc<CommunityArticleDetailEvent, CommunityArticleDetailState> {
  CommunityArticleDetailBloc(
    this._getCommunityArticleById,
    this._deleteCommunityArticle,
  ) : super(const CommunityArticleDetailState()) {
    on<CommunityArticleDetailStarted>(_onStarted);
    on<CommunityArticleDeleteRequested>(_onDeleteRequested);
  }

  final GetCommunityArticleByIdUseCase _getCommunityArticleById;
  final DeleteCommunityArticleUseCase _deleteCommunityArticle;

  Future<void> _onStarted(
    CommunityArticleDetailStarted event,
    Emitter<CommunityArticleDetailState> emit,
  ) async {
    if (event.article != null) {
      emit(
        state.copyWith(
          status: CommunityArticleDetailStatus.success,
          article: event.article,
          clearFailure: true,
        ),
      );
      return;
    }

    final articleId = event.articleId;
    if (articleId == null || articleId.isEmpty) {
      emit(state.copyWith(status: CommunityArticleDetailStatus.success));
      return;
    }

    emit(
      state.copyWith(
        status: CommunityArticleDetailStatus.loading,
        clearFailure: true,
      ),
    );

    final result = await _getCommunityArticleById(
      params: GetArticleByIdParams(id: articleId),
    );

    switch (result) {
      case DataSuccess<dynamic>(:final data):
        emit(
          state.copyWith(
            status: CommunityArticleDetailStatus.success,
            article: data,
            clearFailure: true,
          ),
        );
      case DataFailed<dynamic>(:final failure):
        emit(
          state.copyWith(
            status: CommunityArticleDetailStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _onDeleteRequested(
    CommunityArticleDeleteRequested event,
    Emitter<CommunityArticleDetailState> emit,
  ) async {
    final article = state.article;
    if (article == null) {
      return;
    }

    emit(
      state.copyWith(
        status: CommunityArticleDetailStatus.deleting,
        clearFailure: true,
      ),
    );

    final result = await _deleteCommunityArticle(
      params: DeleteArticleParams(id: article.id),
    );

    switch (result) {
      case DataSuccess<dynamic>():
        emit(state.copyWith(status: CommunityArticleDetailStatus.deleted));
      case DataFailed<dynamic>(:final failure):
        emit(
          state.copyWith(
            status: CommunityArticleDetailStatus.failure,
            failure: failure,
          ),
        );
    }
  }
}
