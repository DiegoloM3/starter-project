import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_state.dart';

/// Drives the "my articles" list screen.
///
/// Kept as a [Cubit] (not a [Bloc]) because the screen only ever triggers
/// two intents — `load` and `delete` — with no stream of typed events to
/// exhaustively reason about.
class MyArticlesCubit extends Cubit<MyArticlesState> {
  MyArticlesCubit({
    required GetMyArticlesUseCase getMyArticles,
    required DeleteArticleUseCase deleteArticle,
  })  : _getMyArticles = getMyArticles,
        _deleteArticle = deleteArticle,
        super(const MyArticlesState.initial());

  final GetMyArticlesUseCase _getMyArticles;
  final DeleteArticleUseCase _deleteArticle;

  Future<void> load(String authorId) async {
    emit(const MyArticlesState.loading());
    final result = await _getMyArticles(authorId);
    result.fold(
      (failure) => emit(MyArticlesState.failure(failure)),
      (articles) => emit(MyArticlesState.success(articles)),
    );
  }

  /// Optimistically removes the article from the current list, falls back to
  /// re-fetching on failure. Keeps the UI snappy without risking a stale
  /// view if Firestore rejects the delete.
  Future<void> delete({required String authorId, required String id}) async {
    final current = state;
    if (current is MyArticlesSuccess) {
      emit(
        MyArticlesState.success(
          current.articles.where((a) => a.id != id).toList(),
        ),
      );
    }
    final result = await _deleteArticle(DeleteArticleParams(id: id));
    await result.fold(
      (failure) async {
        emit(MyArticlesState.failure(failure));
        await load(authorId);
      },
      (_) async {},
    );
  }
}
