import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_state.dart';

@injectable
final class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase)
    : super(const RemoteArticlesLoading()) {
    on<RemoteArticlesEvent>(_onRemoteArticlesEvent);
  }

  Future<void> _onRemoteArticlesEvent(
    RemoteArticlesEvent event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    switch (event) {
      case GetArticles():
        await _loadInitialArticles(emit);
      case LoadMoreArticles():
        await _loadMoreArticles(emit);
    }
  }

  /// Handles the initial load of articles (page 1).
  Future<void> _loadInitialArticles(Emitter<RemoteArticlesState> emit) async {
    emit(const RemoteArticlesLoading());

    final dataState = await _getArticleUseCase(
      params: const ArticleParams(page: 1),
    );

    switch (dataState) {
      case DataSuccess<dynamic>(:final data):
        emit(
          RemoteArticlesDone(
            data.articles,
            currentPage: data.page,
            hasMore: data.hasMore,
            isLoadingMore: false,
          ),
        );
      case DataFailed<dynamic>(:final failure):
        emit(RemoteArticlesError(failure));
    }
  }

  /// Handles loading the next page of articles (infinite scroll).
  Future<void> _loadMoreArticles(Emitter<RemoteArticlesState> emit) async {
    switch (state) {
      // Only proceed if we have a successful state with more pages available.
      case RemoteArticlesDone(
        :final articles?,
        :final currentPage,
        hasMore: true,
        isLoadingMore: false,
      ):
        emit(
          RemoteArticlesDone(
            articles,
            currentPage: currentPage,
            hasMore: true,
            isLoadingMore: true,
          ),
        );

        final nextPage = currentPage + 1;
        final dataState = await _getArticleUseCase(
          params: ArticleParams(page: nextPage),
        );

        switch (dataState) {
          case DataSuccess<dynamic>(:final data):
            final allArticles = <ArticleEntity>[...articles, ...data.articles];
            emit(
              RemoteArticlesDone(
                allArticles,
                currentPage: nextPage,
                hasMore: data.hasMore,
                isLoadingMore: false,
              ),
            );
          case DataFailed<dynamic>():
            // Return to previous state on error, but keep existing articles.
            emit(
              RemoteArticlesDone(
                articles,
                currentPage: currentPage,
                hasMore: true,
                isLoadingMore: false,
              ),
            );
        }
      case _:
        return;
    }
  }
}
