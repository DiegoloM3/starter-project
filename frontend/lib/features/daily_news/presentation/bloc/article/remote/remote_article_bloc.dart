import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {

  final GetNewsFeedUseCase _getNewsFeedUseCase;

  RemoteArticlesBloc(this._getNewsFeedUseCase) : super(const RemoteArticlesLoading()){
    on <GetArticles> (onGetArticles);
  }


  Future<void> onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final stateWhileLoading = _buildStateWhileLoading();
    if (stateWhileLoading != state) {
      emit(stateWhileLoading);
    }
    final dataState = await _getNewsFeedUseCase();

    if (dataState is DataSuccess) {
      emit(
        RemoteArticlesDone(dataState.data!)
      );
    }

    if (dataState is DataFailed) {
      emit(
        RemoteArticlesError(dataState.error!)
      );
    }
  }

  /// Keeps the current articles on screen while they are loaded again.
  RemoteArticlesState _buildStateWhileLoading() {
    final currentArticles = state.articles;
    if (currentArticles == null) {
      return const RemoteArticlesLoading();
    }
    return RemoteArticlesRefreshing(currentArticles);
  }

}
