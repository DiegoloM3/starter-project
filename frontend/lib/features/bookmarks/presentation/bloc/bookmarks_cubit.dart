import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_state.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';

class BookmarksCubit extends Cubit<BookmarksState> {
  final GetSavedArticlesUseCase _getSavedArticles;
  final UnsaveArticleUseCase _unsaveArticle;

  static const int _pageSize = 10;

  BookmarksCubit(this._getSavedArticles, this._unsaveArticle)
      : super(const BookmarksInitial());

  Future<void> loadBookmarks(String userId) async {
    emit(const BookmarksLoading());
    final result = await _getSavedArticles(
      GetSavedArticlesParams(userId: userId, limit: _pageSize),
    );
    if (result.isSuccess) {
      final articles = result.data!;
      if (articles.isEmpty) {
        emit(const BookmarksEmpty());
      } else {
        emit(BookmarksLoaded(
          articles: articles,
          hasMore: articles.length >= _pageSize,
        ));
      }
    } else {
      emit(BookmarksError(_mapErrorToMessage(result.error!)));
    }
  }

  Future<void> loadMore(String userId) async {
    final current = state;
    if (current is! BookmarksLoaded || !current.hasMore) return;

    final newLimit = current.articles.length + _pageSize;
    final result = await _getSavedArticles(
      GetSavedArticlesParams(userId: userId, limit: newLimit),
    );
    if (result.isSuccess) {
      final articles = result.data!;
      emit(BookmarksLoaded(
        articles: articles,
        hasMore: articles.length >= newLimit,
      ));
    }
    // On failure keep current state — no revert needed since state didn't change
  }

  Future<void> unsaveArticle(String userId, String articleId) async {
    final current = state;
    if (current is! BookmarksLoaded) return;

    final updatedArticles =
        current.articles.where((a) => a.id != articleId).toList();
    final optimisticState = updatedArticles.isEmpty
        ? const BookmarksEmpty()
        : BookmarksLoaded(
            articles: updatedArticles,
            hasMore: current.hasMore,
          ) as BookmarksState;

    emit(optimisticState);

    final result = await _unsaveArticle(
      UnsaveArticleParams(userId: userId, articleId: articleId),
    );
    if (result.isFailure) {
      // Revert to the state before the optimistic update
      emit(current);
    }
  }

  String _mapErrorToMessage(Exception error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => 'No tienes permiso para realizar esta acción',
        'not-found' => 'El contenido no existe',
        'unavailable' => 'Sin conexión. Inténtalo de nuevo',
        _ => 'Algo salió mal. Inténtalo de nuevo',
      };
    }
    return 'Algo salió mal. Inténtalo de nuevo';
  }
}
