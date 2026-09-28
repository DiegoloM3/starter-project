


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_article.dart';


part 'remote_article_event.dart';
part 'remote_article_state.dart';


class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc({required GetArticleUseCase getArticleUseCase})
      : _getArticleUseCase = getArticleUseCase,
        super(const RemoteArticlesLoading()) {
    on<GetArticlesEvent>(_onGetArticles);
  }

  Future<void> _onGetArticles(GetArticlesEvent event, Emitter<RemoteArticlesState> emit) async {
   emit(RemoteArticlesLoading());  
  final dataState = await _getArticleUseCase.call();

  switch (dataState) {
    case DataSuccess(data: final articles):
      if (articles != null && articles.isNotEmpty) {
        emit(RemoteArticlesDone(articles: articles));
      }
    case DataFailed(error: final error):
      emit(RemoteArticlesError(error: error!));
  }
}


}
