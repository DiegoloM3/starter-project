import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/get_my_uploaded_articles.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_state.dart';

class MyUploadedArticlesCubit extends Cubit<MyUploadedArticlesState> {
  final GetMyUploadedArticlesUseCase _getMyUploadedArticlesUseCase;

  MyUploadedArticlesCubit(this._getMyUploadedArticlesUseCase)
      : super(const MyUploadedArticlesLoading());

  Future<void> load() async {
    emit(const MyUploadedArticlesLoading());

    final result = await _getMyUploadedArticlesUseCase();
    if (result is DataSuccess<List<ArticleEntity>>) {
      emit(MyUploadedArticlesDone(result.data ?? const <ArticleEntity>[]));
      return;
    }

    emit(
      MyUploadedArticlesError(
        result.error?.message ?? 'Unable to load uploaded articles',
      ),
    );
  }
}
