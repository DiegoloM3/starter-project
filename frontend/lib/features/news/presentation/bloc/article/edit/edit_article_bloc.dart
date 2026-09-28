import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart';

part 'edit_article_event.dart';
part 'edit_article_state.dart';

@injectable
/// UI state machine for editing or deleting a user article.
class EditArticleBloc extends Bloc<EditArticleEvent, EditArticleState> {
  final UpdateUserArticle _updateUserArticle;
  final DeleteUserArticle _deleteUserArticle;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  EditArticleBloc(
    this._updateUserArticle,
    this._deleteUserArticle,
    this._getCurrentUserUseCase,
  ) : super(const EditArticleIdle()) {
    on<SaveArticleEdits>(_onSaveArticleEdits);
    on<DeleteArticleRequested>(_onDeleteArticleRequested);
    on<ResetEditArticle>(_onReset);
  }

  Future<void> _onSaveArticleEdits(
    SaveArticleEdits event,
    Emitter<EditArticleState> emit,
  ) async {
    if (event.title.trim().isEmpty) {
      emit(const EditArticleError('Title cannot be empty.'));
      return;
    }
    if (event.content.trim().isEmpty) {
      emit(const EditArticleError('Content cannot be empty.'));
      return;
    }

    final editorId = await _currentUserId();
    if (editorId == null) {
      emit(const EditArticleError('Please log in to edit your article.'));
      return;
    }
    if (editorId != event.original.authorId) {
      emit(const EditArticleError('You can only edit your own articles.'));
      return;
    }

    emit(const EditArticleLoading());

    final updated = ArticleEntity(
      id: event.original.id,
      authorDisplayName: event.original.authorDisplayName,
      title: event.title.trim(),
      urlToImage: event.original.urlToImage,
      publishedAt: event.original.publishedAt,
      content: event.content.trim(),
      authorId: event.original.authorId,
    );

    final result = await _updateUserArticle(
      params: UpdateUserArticleParams(
        article: updated,
        imageFile: event.imageFile,
      ),
    );

    if (result is DataSuccess) {
      emit(const EditArticleSaved());
    } else {
      emit(EditArticleError(
        result.errorMessage ?? result.error?.toString() ?? 'Unknown error.',
      ));
    }
  }

  Future<void> _onDeleteArticleRequested(
    DeleteArticleRequested event,
    Emitter<EditArticleState> emit,
  ) async {
    final articleId = event.article.id?.trim() ?? '';
    if (articleId.isEmpty) {
      emit(const EditArticleError('Cannot delete an article without an id.'));
      return;
    }

    final editorId = await _currentUserId();
    if (editorId == null) {
      emit(const EditArticleError('Please log in to delete your article.'));
      return;
    }
    if (editorId != event.article.authorId) {
      emit(const EditArticleError('You can only delete your own articles.'));
      return;
    }

    emit(const EditArticleLoading());

    final result = await _deleteUserArticle(
      params: DeleteUserArticleParams(articleId: articleId),
    );

    if (result is DataSuccess) {
      emit(const EditArticleDeleted());
    } else {
      emit(EditArticleError(
        result.errorMessage ?? result.error?.toString() ?? 'Unknown error.',
      ));
    }
  }

  /// Returns the current user id, or null when logged out.
  Future<String?> _currentUserId() async {
    final user = await _getCurrentUserUseCase();
    if (user is DataSuccess && user.data != null) return user.data!.id;
    return null;
  }

  void _onReset(
    ResetEditArticle event,
    Emitter<EditArticleState> emit,
  ) {
    emit(const EditArticleIdle());
  }
}
