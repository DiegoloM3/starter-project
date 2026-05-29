import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../domain/usecases/get_saved_article.dart';
import '../../../../domain/usecases/remove_article.dart';
import '../../../../domain/usecases/save_article.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
  ) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }

  Future<void> onGetSavedArticles(
    GetSavedArticles event,
    Emitter<LocalArticlesState> emit,
  ) async {
    final dataState = await _getSavedArticleUseCase();
    _emitFromDataState(dataState, emit);
  }

  Future<void> onRemoveArticle(
    RemoveArticle removeArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final dataState = await _removeArticleUseCase(params: removeArticle.article);
    if (dataState is DataFailed) {
      emit(LocalArticlesFailure(dataState.error!));
      return;
    }
    final savedState = await _getSavedArticleUseCase();
    _emitFromDataState(savedState, emit);
  }

  Future<void> onSaveArticle(
    SaveArticle saveArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final dataState = await _saveArticleUseCase(params: saveArticle.article);
    if (dataState is DataFailed) {
      emit(LocalArticlesFailure(dataState.error!));
      return;
    }
    final savedState = await _getSavedArticleUseCase();
    _emitFromDataState(savedState, emit);
  }

  void _emitFromDataState(
    DataState<List<ArticleEntity>> dataState,
    Emitter<LocalArticlesState> emit,
  ) {
    if (dataState is DataFailed) {
      emit(LocalArticlesFailure(dataState.error!));
      return;
    }
    emit(LocalArticlesDone(dataState.data!));
  }
}