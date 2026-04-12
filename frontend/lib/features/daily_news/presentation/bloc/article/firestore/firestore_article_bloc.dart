import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';

class FirestoreArticlesBloc
    extends Bloc<FirestoreArticlesEvent, FirestoreArticlesState> {
  final GetFirestoreArticlesUseCase _getFirestoreArticlesUseCase;

  FirestoreArticlesBloc(this._getFirestoreArticlesUseCase)
      : super(const FirestoreArticlesLoading()) {
    on<GetFirestoreArticles>(_onGetFirestoreArticles);
  }

  Future<void> _onGetFirestoreArticles(
    GetFirestoreArticles event,
    Emitter<FirestoreArticlesState> emit,
  ) async {
    emit(const FirestoreArticlesLoading());

    final dataState = await _getFirestoreArticlesUseCase();

    if (dataState is DataSuccess) {
      emit(FirestoreArticlesDone(dataState.data ?? []));
    } else if (dataState is DataFailed) {
      emit(FirestoreArticlesError(dataState.failure!.type));
    }
  }
}
