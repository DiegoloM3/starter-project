import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetNewsArticlesUseCase _getNewsArticlesUseCase;

  RemoteArticlesBloc(this._getNewsArticlesUseCase) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(_onGetArticles);
  }

  Future<void> _onGetArticles(GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _getNewsArticlesUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }
}
