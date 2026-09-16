import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';

part 'my_articles_state.dart';

/// The signed-in journalist's own articles, newest first, with delete.
/// App-wide so the Profile counter and My Articles share one list and a
/// publish or delete anywhere updates both.
class MyArticlesCubit extends Cubit<MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticles;
  final DeleteArticleUseCase _deleteArticle;

  MyArticlesCubit(this._getMyArticles, this._deleteArticle) : super(const MyArticlesState());

  Future<void> load() async {
    emit(state.copyWith(status: MyArticlesStatus.loading));
    final result = await _getMyArticles(const NoParams());
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess(:final data) => state.copyWith(status: MyArticlesStatus.loaded, articles: data),
      DataFailed(:final failure) =>
        state.copyWith(status: MyArticlesStatus.failure, failure: failure),
    });
  }

  /// Puts a freshly published or edited article in the list without a
  /// round trip.
  void upsert(ArticleEntity article) {
    final others = state.articles.where((a) => a.id != article.id);
    final articles = [article, ...others]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    emit(state.copyWith(status: MyArticlesStatus.loaded, articles: articles));
  }

  Future<bool> delete(ArticleEntity article) async {
    final result = await _deleteArticle(article);
    if (isClosed) return false;
    switch (result) {
      case DataSuccess():
        emit(state.copyWith(articles: state.articles.where((a) => a.id != article.id).toList()));
        return true;
      case DataFailed(:final failure):
        emit(state.copyWith(failure: failure));
        return false;
    }
  }

  /// Forgets everything, e.g. when the account signs out.
  void reset() => emit(const MyArticlesState());
}
