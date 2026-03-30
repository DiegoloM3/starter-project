import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article.dart';
import 'upload_article_state.dart';

class UploadArticleCubit extends Cubit<UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleCubit(this._uploadArticleUseCase) : super(const UploadArticleInitial());

  Future<void> uploadArticle(ArticleEntity article) async {
    emit(const UploadArticleLoading());
    try {
      await _uploadArticleUseCase(params: article);
      emit(const UploadArticleDone());
    } catch (e) {
      emit(UploadArticleError(e.toString()));
    }
  }
}
