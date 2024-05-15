import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_article_to_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  final AddArticleToFirestoreUseCase _addArticleToFirestoreUseCase;
  final GetArticlesFromFirestoreUseCase _getArticlesFromFirestoreUseCase;

  RemoteArticlesBloc(this._getArticleUseCase,
      this._addArticleToFirestoreUseCase, this._getArticlesFromFirestoreUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<AddArticle>(onAddArticle);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.exception!));
    }
  }

  void onAddArticle(
      AddArticle addArticle, Emitter<RemoteArticlesState> emit) async {
    await _addArticleToFirestoreUseCase(params: addArticle.article);
    final dataState = await _getArticlesFromFirestoreUseCase();

    if (dataState is DataSuccess) {
      emit(RemoteArticlesDone(dataState.data!));
    }

    if (dataState is FireFailed) {
      emit(FireArticlesError(dataState.fireException!));
    }
  }
}
