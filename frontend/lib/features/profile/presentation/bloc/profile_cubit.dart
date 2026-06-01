import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/delete_article_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_published_articles_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_current_user_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final GetSavedArticlesUseCase _getSavedArticles;
  final GetPublishedArticlesUseCase _getPublishedArticles;
  final DeleteArticleUseCase _deleteArticle;
  final GetAllCategoriesUseCase _getAllCategories;
  final UpdateUserRoleUseCase _updateUserRole;

  ProfileCubit(
    this._getCurrentUser,
    this._getSavedArticles,
    this._getPublishedArticles,
    this._deleteArticle,
    this._getAllCategories,
    this._updateUserRole,
  ) : super(const ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileLoading());

    final userFuture = _getCurrentUser(const NoParams());
    final savedFuture = _getSavedArticles(GetSavedArticlesParams(userId: userId, limit: 100));
    final publishedFuture = _getPublishedArticles(GetPublishedArticlesParams(authorId: userId, limit: 100));
    final categoriesFuture = _getAllCategories(const NoParams());

    final userResult = await userFuture;
    final savedResult = await savedFuture;
    final publishedResult = await publishedFuture;
    final categoriesResult = await categoriesFuture;

    if (userResult.isFailure) {
      emit(ProfileError(_mapErrorToMessage(userResult.error!)));
      return;
    }
    if (savedResult.isFailure) {
      emit(ProfileError(_mapErrorToMessage(savedResult.error!)));
      return;
    }
    if (publishedResult.isFailure) {
      emit(ProfileError(_mapErrorToMessage(publishedResult.error!)));
      return;
    }

    final publishedArticles = publishedResult.data!;
    emit(ProfileLoaded(
      user: userResult.data!,
      savedArticles: savedResult.data!,
      publishedArticles: publishedArticles,
      totalPublishedCount: publishedArticles.length,
      categories: categoriesResult.isSuccess ? (categoriesResult.data ?? []) : [],
    ));
  }

  Future<void> deleteArticle(String articleId, String userId) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final result = await _deleteArticle(
      DeleteArticleParams(articleId: articleId, userId: userId),
    );

    if (result.isFailure) {
      emit(ProfileError(_mapErrorToMessage(result.error!)));
      return;
    }

    final updatedPublished = currentState.publishedArticles
        .where((a) => a.id != articleId)
        .toList();
    final updatedSaved = currentState.savedArticles
        .where((a) => a.id != articleId)
        .toList();

    emit(ProfileArticleDeleted(articleId));
    emit(ProfileLoaded(
      user: currentState.user,
      savedArticles: updatedSaved,
      publishedArticles: updatedPublished,
      totalPublishedCount: updatedPublished.length,
    ));
  }

  Future<bool> toggleRole(String userId, String newRole) async {
    final result = await _updateUserRole(
      UpdateUserRoleParams(userId: userId, role: newRole),
    );
    return result.isSuccess;
  }

  String _mapErrorToMessage(Exception error) {
    return 'Algo salió mal. Inténtalo de nuevo';
  }
}
