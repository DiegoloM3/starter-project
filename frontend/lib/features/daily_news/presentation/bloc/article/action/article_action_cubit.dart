import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/action/article_action_state.dart';

class ArticleActionCubit extends Cubit<ArticleActionState> {
  final DeleteArticleUseCase _deleteArticleUseCase;

  ArticleActionCubit(this._deleteArticleUseCase)
      : super(const ArticleActionInitial());

  Future<void> deleteArticle(String articleId) async {
    emit(const ArticleActionInProgress());
    final result = await _deleteArticleUseCase(params: articleId);
    if (result is DataSuccess) {
      emit(const ArticleActionDeleteSuccess());
    }
    if (result is DataFailed) {
      emit(ArticleActionFailure(result.error!));
    }
  }
}
