import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_draft_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_state.dart';

class DraftsListBloc extends Bloc<DraftsListEvent, DraftsListState> {
  final GetDraftArticlesUseCase _getDraftArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;

  DraftsListBloc(
    this._getDraftArticlesUseCase,
    this._deleteArticleUseCase,
  ) : super(const DraftsListLoading()) {
    on<DraftsSubscriptionRequested>(_onSubscriptionRequested);
    on<DraftDeleted>(_onDraftDeleted);
  }

  void _onSubscriptionRequested(
    DraftsSubscriptionRequested event,
    Emitter<DraftsListState> emit,
  ) async {
    emit(const DraftsListLoading());

    await _subscription?.cancel();

    await emit.forEach<DataState<List<ArticleEntity>>>(
      _getDraftArticlesUseCase(params: event.userId),
      onData: (dataState) {
        if (dataState is DataSuccess<List<ArticleEntity>>) {
          return DraftsListDone(dataState.data ?? const []);
        }
        if (dataState is DataFailed<List<ArticleEntity>>) {
          return DraftsListFailure(dataState.error!);
        }
        return const DraftsListLoading();
      },
      onError: (error, stackTrace) => DraftsListFailure(
        AppException(message: error.toString()),
      ),
    );
  }

  Future<void> _onDraftDeleted(
    DraftDeleted event,
    Emitter<DraftsListState> emit,
  ) async {
    await _deleteArticleUseCase(params: event.articleId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
