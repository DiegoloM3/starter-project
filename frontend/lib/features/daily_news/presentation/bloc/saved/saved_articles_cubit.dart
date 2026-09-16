import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';

part 'saved_articles_state.dart';

/// The on-device bookmarks, shared by the Saved tab and the Reader's Save
/// button so both always agree. Removals keep the last article around so a
/// snackbar can offer Undo.
class SavedArticlesCubit extends Cubit<SavedArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticles;
  final SaveArticleUseCase _saveArticle;
  final RemoveSavedArticleUseCase _removeSavedArticle;

  SavedArticlesCubit(this._getSavedArticles, this._saveArticle, this._removeSavedArticle)
      : super(const SavedArticlesState());

  Future<void> load() async {
    emit(state.copyWith(status: SavedStatus.loading));
    final result = await _getSavedArticles(const NoParams());
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess(:final data) => state.copyWith(status: SavedStatus.loaded, articles: data),
      DataFailed(:final failure) => state.copyWith(status: SavedStatus.failure, failure: failure),
    });
  }

  bool isSaved(String articleId) => state.savedIds.contains(articleId);

  /// Saves an unsaved article, removes a saved one.
  Future<void> toggle(ArticleEntity article) =>
      isSaved(article.id) ? remove(article) : save(article);

  Future<void> save(ArticleEntity article) async {
    final result = await _saveArticle(article);
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess() => state.copyWith(
          articles: [article, ...state.articles.where((a) => a.id != article.id)],
          lastRemoved: null,
        ),
      DataFailed(:final failure) => state.copyWith(failure: failure),
    });
  }

  Future<void> remove(ArticleEntity article) async {
    final result = await _removeSavedArticle(article.id);
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess() => state.copyWith(
          articles: state.articles.where((a) => a.id != article.id).toList(),
          lastRemoved: article,
        ),
      DataFailed(:final failure) => state.copyWith(failure: failure),
    });
  }

  Future<void> undoRemove() async {
    final article = state.lastRemoved;
    if (article != null) await save(article);
  }

  /// Back to a fresh start: the next visit to Saved loads again.
  void reset() => emit(const SavedArticlesState());
}
