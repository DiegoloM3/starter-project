import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_state.dart';

class UploadArticleCubit extends Cubit<UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleCubit({
    required UploadArticleUseCase uploadArticleUseCase,
  })  : _uploadArticleUseCase = uploadArticleUseCase,
        super(const UploadArticleInitial());

  Future<void> uploadArticle({
    required String title,
    required String content,
    required String author,
    required String thumbnailPath,
    String? description,
    String? category,
  }) async {
    emit(const UploadArticleLoading());

    try {
      final params = CreateArticleParams(
        title: title,
        content: content,
        author: author,
        thumbnailPath: thumbnailPath,
        description: description,
        category: category,
      );

      final result = await _uploadArticleUseCase(params: params);

      if (result is DataSuccess) {
        emit(UploadArticleSuccess(article: (result as DataSuccess).data));
      } else if (result is DataFailed) {
        emit(UploadArticleFailure(
          error: (result as DataFailed).error?.message ?? 'Upload failed',
        ));
      }
    } catch (e) {
      emit(UploadArticleFailure(error: e.toString()));
    }
  }

  void resetState() {
    emit(const UploadArticleInitial());
  }

  void validateInput({
    required String title,
    required String content,
    required String author,
  }) {
    final errors = <String, String>{};

    if (title.isEmpty || title.length < 5 || title.length > 200) {
      errors['title'] = 'Title must be between 5 and 200 characters';
    }

    if (content.isEmpty || content.length < 20) {
      errors['content'] = 'Content must be at least 20 characters';
    }

    if (author.isEmpty || author.length < 2 || author.length > 100) {
      errors['author'] = 'Author must be between 2 and 100 characters';
    }

    if (errors.isNotEmpty) {
      emit(UploadArticleValidationError(errors: errors));
    }
  }
}
