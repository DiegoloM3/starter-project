import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../data/models/article.dart';
import '../../../../domain/entities/article.dart';
import '../../../../domain/usecases/get_saved_article.dart';
import '../../../../domain/usecases/remove_article.dart';
import '../../../../domain/usecases/save_article.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticleBloc(this._getSavedArticleUseCase, this._saveArticleUseCase,
      this._removeArticleUseCase)
      : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }

  Future<void> onGetSavedArticles(
    GetSavedArticles event,
    Emitter<LocalArticlesState> emit,
  ) async {
    try {
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (_) {
      emit(const LocalArticlesFailure('Unable to load saved articles.'));
    }
  }

  Future<void> onRemoveArticle(
    RemoveArticle removeArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final article = removeArticle.article!;
    try {
      await _removeArticleUseCase(params: article);
    } catch (_) {
      emit(LocalArticlesFailure(
        'Unable to remove the saved article.',
        articles: state.articles ?? const [],
      ));
      return;
    }
    try {
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (_) {
      final key = articleBookmarkKey(article);
      final articles = (state.articles ?? const <ArticleEntity>[])
          .where((item) => articleBookmarkKey(item) != key)
          .toList(growable: false);
      emit(LocalArticlesDone(
        articles,
        warning: 'Article removed, but the saved list could not be refreshed.',
      ));
    }
  }

  Future<void> onSaveArticle(
    SaveArticle saveArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final article = saveArticle.article!;
    try {
      await _saveArticleUseCase(params: article);
    } catch (_) {
      emit(LocalArticlesFailure(
        'Unable to save the article.',
        articles: state.articles ?? const [],
      ));
      return;
    }
    try {
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (_) {
      final key = articleBookmarkKey(article);
      final articles = [
        ...(state.articles ?? const <ArticleEntity>[])
            .where((item) => articleBookmarkKey(item) != key),
        article,
      ];
      emit(LocalArticlesDone(
        articles,
        warning: 'Article saved, but the saved list could not be refreshed.',
      ));
    }
  }
}
