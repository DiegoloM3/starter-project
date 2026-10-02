import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_saved_journalist_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';

import 'saved_journalist_articles_state.dart';

/// The journalists' articles that the signed-in journalist saved.
class SavedJournalistArticlesCubit extends Cubit<SavedJournalistArticlesState> {
  final GetSavedJournalistArticlesUseCase _getSavedArticlesUseCase;
  final RemoveSavedJournalistArticleUseCase _removeSavedArticleUseCase;

  SavedJournalistArticlesCubit(this._getSavedArticlesUseCase, this._removeSavedArticleUseCase)
      : super(const SavedJournalistArticlesInProgress());

  /// When refreshing, the articles already shown stay on screen until the new ones arrive.
  Future<void> loadSavedArticles() async {
    if (state is! SavedJournalistArticlesSuccess) emit(const SavedJournalistArticlesInProgress());
    final dataState = await _getSavedArticlesUseCase();
    if (dataState is DataSuccess) {
      emit(SavedJournalistArticlesSuccess(dataState.data!));
      return;
    }
    emit(SavedJournalistArticlesFailure(dataState.error!));
  }

  Future<void> removeSavedArticle(JournalistArticleEntity article) async {
    final state = this.state;
    if (state is! SavedJournalistArticlesSuccess) return;
    final dataState = await _removeSavedArticleUseCase(params: article.id);
    if (dataState is DataSuccess) {
      emit(SavedJournalistArticleRemoved(state.articles.where((saved) => saved.id != article.id).toList()));
      return;
    }
    emit(SavedJournalistArticleRemoveFailure(state.articles, dataState.error!));
  }
}
