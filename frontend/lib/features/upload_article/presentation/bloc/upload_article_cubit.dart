import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/upload_article_params.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_state.dart';

class UploadArticleCubit extends Cubit<UploadArticleState> {
  final UploadArticleUseCase _uploadArticle;
  final UpdateArticleUseCase _updateArticle;

  UploadArticleCubit(this._uploadArticle, this._updateArticle)
      : super(const UploadArticleIdle());

  Future<void> submit({
    required String title,
    required String description,
    required String content,
    required List<int> thumbnailBytes,
    required String thumbnailFileName,
  }) async {
    emit(const UploadArticleSubmitting());
    try {
      final article = await _uploadArticle(
        params: UploadArticleParams(
          title: title,
          description: description,
          content: content,
          thumbnailBytes: thumbnailBytes,
          thumbnailFileName: thumbnailFileName,
        ),
      );
      emit(UploadArticleSuccess(article));
    } on UploadArticleException catch (e) {
      emit(UploadArticleFailure(e.message));
    }
  }

  Future<void> update({
    required String articleId,
    required String title,
    required String description,
    required String content,
    List<int>? newThumbnailBytes,
    String? newThumbnailFileName,
  }) async {
    emit(const UploadArticleSubmitting());
    try {
      final article = await _updateArticle(
        params: UpdateArticleParams(
          articleId: articleId,
          title: title,
          description: description,
          content: content,
          newThumbnailBytes: newThumbnailBytes,
          newThumbnailFileName: newThumbnailFileName,
        ),
      );
      emit(UploadArticleSuccess(article));
    } on UploadArticleException catch (e) {
      emit(UploadArticleFailure(e.message));
    }
  }

  void reset() => emit(const UploadArticleIdle());
}
