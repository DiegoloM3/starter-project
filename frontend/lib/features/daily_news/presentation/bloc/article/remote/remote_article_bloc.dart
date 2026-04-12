import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  int _currentPage = 1;

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(_onGetArticles);
    on<LoadMoreArticles>(_onLoadMore);
  }

  Future<void> _onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    _currentPage = 1;
    emit(const RemoteArticlesLoading());

    final dataState = await _getArticleUseCase(params: _currentPage);

    if (dataState is DataSuccess<List<ArticleEntity>>) {
      final articles = dataState.data ?? [];
      if (dataState.isCached) {
        emit(RemoteArticlesCached(articles));
      } else {
        emit(RemoteArticlesDone(articles, hasMore: articles.isNotEmpty));
      }
    } else if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.failure!.type));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    if (!state.hasMore) return;
    final existing = state.articles ?? [];

    emit(RemoteArticlesLoadingMore(existing));

    final nextPage = _currentPage + 1;
    final dataState = await _getArticleUseCase(params: nextPage);

    if (dataState is DataSuccess<List<ArticleEntity>>) {
      _currentPage = nextPage;
      final newArticles = dataState.data ?? [];
      final all = [...existing, ...newArticles];
      emit(RemoteArticlesDone(all, hasMore: newArticles.isNotEmpty));
    } else {
      emit(RemoteArticlesDone(existing));
    }
  }
}
