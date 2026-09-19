import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {
  
  final GetArticleUseCase _getArticleUseCase;
  final PublishArticleUseCase _publishArticleUseCase;
  
  RemoteArticlesBloc(this._getArticleUseCase, this._publishArticleUseCase) : super(const RemoteArticlesLoading()){
    on <GetArticles> (onGetArticles);
    on <PublishArticle> (onPublishArticle);
  }

  Future<void> onPublishArticle(
    PublishArticle event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    await _publishArticleUseCase(params: event.article);
    final currentArticles = state.articles ?? <ArticleEntity>[];
    emit(RemoteArticlesDone([event.article, ...currentArticles]));
  }


  void onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
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
  
}