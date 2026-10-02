import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../domain/use_cases/get_saved_articles.dart';
import '../../../../domain/use_cases/remove_article.dart';

/// The news saved on the phone. Saving them is done from each article, by the ArticleBookmarkCubit.
class LocalArticlesBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticlesUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticlesBloc(this._getSavedArticlesUseCase, this._removeArticleUseCase) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(_onGetSavedArticles);
    on<RemoveArticle>(_onRemoveArticle);
  }

  Future<void> _onGetSavedArticles(GetSavedArticles event, Emitter<LocalArticlesState> emit) async {
    emit(await _readSavedArticles());
  }

  Future<void> _onRemoveArticle(RemoveArticle event, Emitter<LocalArticlesState> emit) async {
    await _removeArticleUseCase(params: event.article);
    emit(await _readSavedArticles());
  }

  Future<LocalArticlesState> _readSavedArticles() async {
    final dataState = await _getSavedArticlesUseCase();
    if (dataState is DataSuccess) return LocalArticlesDone(dataState.data!);
    return LocalArticlesError(dataState.error!);
  }
}
