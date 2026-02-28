import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../../auth/domain/usecases/get_current_user.dart';
import '../../../../domain/entities/article.dart';
import '../../../../domain/usecases/delete_my_article.dart';
import '../../../../domain/usecases/get_my_articles.dart';
import 'my_articles_state.dart';

class MyArticlesCubit extends Cubit<MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticlesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final DeleteMyArticleUseCase _deleteMyArticleUseCase;

  MyArticlesCubit(
    this._getMyArticlesUseCase,
    this._getCurrentUserUseCase,
    this._deleteMyArticleUseCase,
  ) : super(const MyArticlesLoading());

  Future<void> load() async {
    emit(const MyArticlesLoading());

    final user = await _getCurrentUserUseCase();
    if (user == null) {
      emit(const MyArticlesUnauthenticated());
      return;
    }

    final result = await _getMyArticlesUseCase(
      params: GetMyArticlesParams(user.uid),
    );

    if (result is DataSuccess && result.data != null) {
      emit(MyArticlesDone(result.data!));
    } else if (result is DataFailed && result.error != null) {
      emit(MyArticlesError(result.error!));
    }
  }

  Future<void> delete(ArticleEntity article) async {
    await _deleteMyArticleUseCase(params: article);
    await load();
  }
}
