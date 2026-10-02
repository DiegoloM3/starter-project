import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../domain/entities/article.dart';
import '../../../../domain/use_cases/is_article_saved.dart';
import '../../../../domain/use_cases/remove_article.dart';
import '../../../../domain/use_cases/save_article.dart';
import 'article_bookmark_state.dart';

/// Bookmark of a news article from NewsAPI, saved on the phone.
class ArticleBookmarkCubit extends Cubit<ArticleBookmarkState> {
  final IsArticleSavedUseCase _isArticleSavedUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;
  final ArticleEntity _article;

  ArticleBookmarkCubit(
    this._isArticleSavedUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
    this._article,
  ) : super(const ArticleBookmarkInProgress(false));

  /// When it cannot be checked, the article is shown as not saved: saving it again does not duplicate it.
  Future<void> loadBookmark() async {
    final dataState = await _isArticleSavedUseCase(params: _article);
    emit(ArticleBookmarkSuccess(dataState is DataSuccess && dataState.data!));
  }

  Future<void> toggleBookmark() async {
    if (state is ArticleBookmarkInProgress) return;
    final wasSaved = state.isSaved;
    emit(ArticleBookmarkInProgress(wasSaved));
    if (wasSaved) {
      await _removeArticleUseCase(params: _article);
    } else {
      await _saveArticleUseCase(params: _article);
    }
    emit(ArticleBookmarkChanged(!wasSaved));
  }
}
