import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_state.dart';

class UploadArticleCubit extends Cubit<UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleCubit(this._uploadArticleUseCase) : super(const UploadArticleInitial());

  Future<void> upload(UploadArticleEntity article) async {
    emit(const UploadArticleLoading());

    final result = await _uploadArticleUseCase(params: article);

    if (result is DataSuccess<ArticleEntity>) {
      emit(UploadArticleSuccess(result.data!));
      return;
    }

    emit(
      UploadArticleError(
        result.error?.message ?? 'Unexpected error while uploading article',
      ),
    );
  }
}
