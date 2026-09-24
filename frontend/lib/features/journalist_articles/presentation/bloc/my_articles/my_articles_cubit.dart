import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/delete_article_params.dart';
import '../../../domain/params/get_my_articles_params.dart';
import '../../../domain/params/publish_article_params.dart';
import '../../../domain/use_cases/delete_article.dart';
import '../../../domain/use_cases/get_my_articles.dart';
import '../../../domain/use_cases/publish_article.dart';
import 'my_articles_state.dart';

/// Drives the "My articles" screen.
///
/// It owns no business rule: every decision is taken by a use case, the cubit
/// only turns the results into the state the screen renders.
class MyArticlesCubit extends Cubit<MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticles;
  final PublishArticleUseCase _publishArticle;
  final DeleteArticleUseCase _deleteArticle;

  /// Author whose articles are listed. It comes from the signed in user once
  /// authentication is wired; today it is the mock journalist.
  final String journalistId;

  MyArticlesCubit(
    this._getMyArticles,
    this._publishArticle,
    this._deleteArticle, {
    required this.journalistId,
  }) : super(const MyArticlesState());

  Future<void> loadArticles() async {
    emit(state.copyWith(status: MyArticlesStatus.loading, clearError: true));

    final result = await _getMyArticles(
      GetMyArticlesParams(
        userId: journalistId,
        status: state.statusFilter,
        searchQuery: state.searchQuery,
      ),
    );

    if (result is DataSuccess<List<JournalistArticleEntity>>) {
      emit(state.copyWith(
        status: MyArticlesStatus.success,
        articles: result.data,
      ));
      return;
    }

    emit(state.copyWith(
      status: MyArticlesStatus.failure,
      error: result.error,
    ));
  }

  Future<void> filterByStatus(ArticleStatus? status) {
    emit(state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    ));
    return loadArticles();
  }

  Future<void> search(String query) {
    emit(state.copyWith(searchQuery: query));
    return loadArticles();
  }

  Future<void> publishArticle(JournalistArticleEntity article) async {
    final result = await _publishArticle(PublishArticleParams(article));

    if (result is DataFailed) {
      emit(state.copyWith(
        status: MyArticlesStatus.failure,
        error: result.error,
      ));
      return;
    }

    return loadArticles();
  }

  Future<void> deleteArticle(String articleId) async {
    final result = await _deleteArticle(DeleteArticleParams(articleId));

    if (result is DataFailed) {
      emit(state.copyWith(
        status: MyArticlesStatus.failure,
        error: result.error,
      ));
      return;
    }

    return loadArticles();
  }
}
