import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_user_article_by_id_usecase.dart';

import 'user_article_detail_state.dart';

class UserArticleDetailCubit extends Cubit<UserArticleDetailState> {
  final GetUserArticleByIdUseCase _getUserArticleByIdUseCase;
  final DeleteUserArticleUseCase _deleteUserArticleUseCase;

  UserArticleDetailCubit(
    this._getUserArticleByIdUseCase,
    this._deleteUserArticleUseCase,
  ) : super(const UserArticleDetailLoading());

  Future<void> loadArticle(String id) async {
    emit(const UserArticleDetailLoading());
    final result = await _getUserArticleByIdUseCase(params: id);
    if (result is DataSuccess<UserArticleEntity>) {
      emit(UserArticleDetailLoaded(result.data!));
    } else {
      emit(UserArticleDetailError(result.error?.toString() ?? 'Unknown error'));
    }
  }

  Future<void> deleteArticle(String id) async {
    final result = await _deleteUserArticleUseCase(params: id);
    if (result is DataSuccess<bool> && result.data == true) {
      emit(const UserArticleDetailDeleted());
    } else {
      emit(UserArticleDetailError(
          result.error?.toString() ?? 'Could not delete article'));
    }
  }
}
