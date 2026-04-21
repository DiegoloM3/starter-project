import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/list_user_articles.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/list_articles_params.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_state.dart';

class MyArticlesDeps {
  final ListUserArticlesUseCase list;
  final DeleteArticleUseCase delete;

  const MyArticlesDeps({required this.list, required this.delete});
}

class MyArticlesCubit extends Cubit<MyArticlesState> {
  final MyArticlesDeps _deps;

  MyArticlesCubit(this._deps)
      : super(const MyArticlesInitial(ArticlesFilter.mine));

  Future<void> load(ArticlesFilter filter) async {
    emit(MyArticlesLoading(filter));
    try {
      final articles = await _deps.list(params: _paramsFor(filter));
      emit(MyArticlesLoaded(filter, articles));
    } on UploadArticleException catch (e) {
      emit(MyArticlesFailure(filter, e.message));
    }
  }

  Future<void> deleteArticle(String articleId) async {
    final current = state;
    if (current is! MyArticlesLoaded) return;
    try {
      await _deps.delete(params: articleId);
      emit(MyArticlesLoaded(
        current.filter,
        current.articles.where((a) => a.id != articleId).toList(),
      ));
    } on UploadArticleException catch (e) {
      emit(MyArticlesFailure(current.filter, e.message));
    }
  }

  ListArticlesParams _paramsFor(ArticlesFilter filter) {
    switch (filter) {
      case ArticlesFilter.mine:
        return const ListArticlesParams(scope: UserArticlesScope.mine);
      case ArticlesFilter.all:
        return const ListArticlesParams(scope: UserArticlesScope.all);
    }
  }
}
