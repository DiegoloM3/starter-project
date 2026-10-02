import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/is_journalist_article_saved.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/save_journalist_article.dart';

import 'journalist_article_bookmark_state.dart';

/// Bookmark of the article with ID [_articleId], saved in the journalist's account.
class JournalistArticleBookmarkCubit extends Cubit<JournalistArticleBookmarkState> {
  final IsJournalistArticleSavedUseCase _isArticleSavedUseCase;
  final SaveJournalistArticleUseCase _saveArticleUseCase;
  final RemoveSavedJournalistArticleUseCase _removeSavedArticleUseCase;
  final String _articleId;

  JournalistArticleBookmarkCubit(
    this._isArticleSavedUseCase,
    this._saveArticleUseCase,
    this._removeSavedArticleUseCase,
    this._articleId,
  ) : super(const JournalistArticleBookmarkInProgress(false));

  /// When it cannot be checked, the article is shown as not saved.
  Future<void> loadBookmark() async {
    final dataState = await _isArticleSavedUseCase(params: _articleId);
    emit(JournalistArticleBookmarkSuccess(dataState is DataSuccess && dataState.data!));
  }

  Future<void> toggleBookmark() async {
    if (state is JournalistArticleBookmarkInProgress) return;
    final wasSaved = state.isSaved;
    emit(JournalistArticleBookmarkInProgress(wasSaved));
    final dataState = wasSaved
        ? await _removeSavedArticleUseCase(params: _articleId)
        : await _saveArticleUseCase(params: _articleId);
    if (dataState is DataSuccess) {
      emit(JournalistArticleBookmarkChanged(!wasSaved));
      return;
    }
    emit(JournalistArticleBookmarkFailure(wasSaved, dataState.error!));
  }
}
