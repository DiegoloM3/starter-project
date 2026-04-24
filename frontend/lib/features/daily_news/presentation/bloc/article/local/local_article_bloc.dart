import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../domain/usecases/get_saved_article.dart';
import '../../../../domain/usecases/remove_article.dart';
import '../../../../domain/usecases/save_article.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent,LocalArticlesState> {
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class LocalArticlesBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
>>>>>>> fbce432 (Finish PR (project setup))
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

<<<<<<< HEAD
  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase
  ) : super(const LocalArticlesLoading()){
    on <GetSavedArticles> (onGetSavedArticles);
    on <RemoveArticle> (onRemoveArticle);
    on <SaveArticle> (onSaveArticle);
  }


  void onGetSavedArticles(GetSavedArticles event,Emitter<LocalArticlesState> emit) async {
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles));
  }
  
  void onRemoveArticle(RemoveArticle removeArticle,Emitter<LocalArticlesState> emit) async {
    await _removeArticleUseCase(params: removeArticle.article);
=======
  LocalArticlesBloc(
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
>>>>>>> fbce432 (Finish PR (project setup))
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles));
  }

<<<<<<< HEAD
  void onSaveArticle(SaveArticle saveArticle,Emitter<LocalArticlesState> emit) async {
    await _saveArticleUseCase(params: saveArticle.article);
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles));
  }
}
=======
  Future<void> onRemoveArticle(
    RemoveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    await _removeArticleUseCase(params: event.article);
    final current = state is LocalArticlesDone
        ? (state as LocalArticlesDone).articles
        : <ArticleEntity>[];
    emit(LocalArticlesDone(
      current.where((a) => a.id != event.article.id).toList(),
    ));
  }

  Future<void> onSaveArticle(
    SaveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    await _saveArticleUseCase(params: event.article);
    final current = state is LocalArticlesDone
        ? (state as LocalArticlesDone).articles
        : <ArticleEntity>[];
    emit(LocalArticlesDone([event.article, ...current]));
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
