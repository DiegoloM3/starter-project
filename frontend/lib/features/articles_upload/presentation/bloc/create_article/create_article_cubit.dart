import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticle;

  CreateArticleCubit(this._createArticle) : super(const CreateArticleIdle());

  Future<void> submit(CreateArticleParams params) async {
    emit(const CreateArticleSubmitting());
    try {
      final result = await _createArticle(params: params);
      if (result is DataSuccess && result.data != null) {
        emit(CreateArticleSuccess(result.data!));
      } else {
        emit(CreateArticleFailure(
          _readMessage(result.error) ?? 'Unable to publish the article',
        ));
      }
    } catch (e) {
      emit(CreateArticleFailure(e.toString()));
    }
  }

  void reset() => emit(const CreateArticleIdle());

  String? _readMessage(Object? error) {
    if (error == null) return null;
    return error.toString();
  }
}
