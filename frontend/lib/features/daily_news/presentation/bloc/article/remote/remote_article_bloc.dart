import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/post_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {
  
  final GetArticleUseCase _getArticleUseCase;
  final PostArticleUseCase _postArticleUseCase;
  
  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._postArticleUseCase
  ) : super(const RemoteArticlesLoading()){
    on <GetArticles> (onGetArticles);
    on <PostArticle> (onPostArticle);
  }


  void onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final dataState = await _getArticleUseCase(params: event.category);


    if (dataState is DataSuccess) {
      emit(
        RemoteArticlesDone(dataState.data ?? [])
      );
    }
    
    if (dataState is DataFailed) {
      emit(
        RemoteArticlesError(dataState.error!)
      );
    }
  }

  void onPostArticle(PostArticle event, Emitter < RemoteArticlesState > emit) async {
    emit(const PostArticleLoading());
    final dataState = await _postArticleUseCase(params: event.article);

    if (dataState is DataSuccess) {
      emit(const PostArticleSuccess());
      // Refresh articles after successful post
      add(const GetArticles());
    }
    
    if (dataState is DataFailed) {
      emit(PostArticleError(dataState.error!));
    }
  }
}