import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_state.dart';

class EditArticleCubit extends Cubit<EditArticleState> {
  final UpdateArticleUseCase _updateArticleUseCase;

  EditArticleCubit({
    required UpdateArticleUseCase updateArticleUseCase,
  })  : _updateArticleUseCase = updateArticleUseCase,
        super(const EditArticleInitial());

  Future<void> updateArticle({
    required String articleId,
    required String title,
    required String content,
    required String author,
    String? thumbnailPath,
    String? description,
    String? category,
  }) async {
    emit(const EditArticleLoading());

    try {
      final params = UpdateArticleParams(
        articleId: articleId,
        title: title,
        content: content,
        author: author,
        thumbnailPath: thumbnailPath,
        description: description,
        category: category,
      );

      final result = await _updateArticleUseCase(params: params);

      if (result is DataSuccess) {
        emit(EditArticleSuccess(article: (result as DataSuccess).data));
      } else if (result is DataFailed) {
        emit(EditArticleFailure(
          error: (result as DataFailed).error?.message ?? 'Update failed',
        ));
      }
    } catch (e) {
      emit(EditArticleFailure(error: e.toString()));
    }
  }

  void resetState() {
    emit(const EditArticleInitial());
  }
}
