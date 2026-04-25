import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/logger/app_logger.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  final GetArticleUseCase _getArticleUseCase;

  Future<void> onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());
    final result = await _getArticleUseCase(const NoParams());
    result.fold(
      (failure) {
        AppLogger.warn('GetArticles failed: $failure');
        emit(RemoteArticlesError(failure));
      },
      (articles) => emit(RemoteArticlesDone(articles)),
    );
  }
}
