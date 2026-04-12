import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_state.dart';

class EditArticleCubit extends Cubit<CreateArticleState> {
  final UpdateArticleUseCase _updateArticle;

  EditArticleCubit(this._updateArticle) : super(const CreateArticleIdle());

  Future<void> submit(UpdateArticleParams params) async {
    emit(const CreateArticleSubmitting());
    try {
      final result = await _updateArticle(params: params);
      if (result is DataSuccess && result.data != null) {
        emit(CreateArticleSuccess(result.data!));
      } else {
        emit(CreateArticleFailure(
          _readMessage(result.error) ?? 'Unable to update the article',
        ));
      }
    } catch (e) {
      emit(CreateArticleFailure(e.toString()));
    }
  }

  String? _readMessage(Object? error) {
    if (error == null) return null;
    return error.toString();
  }
}
