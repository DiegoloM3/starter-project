import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/user_article.dart';
import '../../../domain/usecases/create_article.dart';
import '../../../domain/usecases/update_article.dart';
import '../../../domain/usecases/publish_article.dart';
import '../../../domain/usecases/upload_image.dart';
import 'article_editor_state.dart';

class ArticleEditorCubit extends Cubit<ArticleEditorState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final PublishArticleUseCase _publishArticleUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  ArticleEditorCubit({
    required CreateArticleUseCase createArticleUseCase,
    required UpdateArticleUseCase updateArticleUseCase,
    required PublishArticleUseCase publishArticleUseCase,
    required UploadImageUseCase uploadImageUseCase,
  })  : _createArticleUseCase = createArticleUseCase,
        _updateArticleUseCase = updateArticleUseCase,
        _publishArticleUseCase = publishArticleUseCase,
        _uploadImageUseCase = uploadImageUseCase,
        super(const ArticleEditorState());

  /// Initialize the editor for a new article
  void initNewArticle() {
    emit(const ArticleEditorState(
      status: ArticleEditorStatus.editing,
      isDraft: true,
    ));
  }

  /// Initialize the editor with an existing article
  void initWithArticle(UserArticleEntity article) {
    emit(ArticleEditorState.fromEntity(article));
  }

  /// Update the title
  void updateTitle(String title) {
    emit(state.copyWith(
      title: title,
      status: ArticleEditorStatus.editing,
      clearError: true,
    ));
  }

  /// Update the content
  void updateContent(String content) {
    final wordCount = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    emit(state.copyWith(
      content: content,
      wordCount: wordCount,
      status: ArticleEditorStatus.editing,
      clearError: true,
    ));
  }

  /// Set a local image path (before upload)
  void setLocalImage(String path) {
    emit(state.copyWith(
      localImagePath: path,
      status: ArticleEditorStatus.editing,
    ));
  }

  /// Add a category/tag
  void addCategory(String category) {
    if (state.categories.contains(category)) return;
    if (state.categories.length >= 5) {
      emit(state.copyWith(
        errorMessage: 'Maximum 5 tags allowed',
      ));
      return;
    }
    final updatedCategories = [...state.categories, category];
    emit(state.copyWith(
      categories: updatedCategories,
      status: ArticleEditorStatus.editing,
      clearError: true,
    ));
  }

  /// Remove a category/tag
  void removeCategory(String category) {
    final updatedCategories =
        state.categories.where((c) => c != category).toList();
    emit(state.copyWith(
      categories: updatedCategories,
      status: ArticleEditorStatus.editing,
      clearError: true,
    ));
  }

  /// Upload the cover image. Returns true if successful or no image to upload.
  Future<bool> uploadCoverImage() async {
    if (state.localImagePath == null) return true;

    emit(state.copyWith(status: ArticleEditorStatus.uploading));

    final file = File(state.localImagePath!);
    final dataState = await _uploadImageUseCase(params: file);

    if (dataState is DataSuccess && dataState.data != null) {
      emit(state.copyWith(
        coverImageUrl: dataState.data,
        status: ArticleEditorStatus.editing,
        clearLocalImage: true,
      ));
      return true;
    } else {
      emit(state.copyWith(
        status: ArticleEditorStatus.error,
        errorMessage: dataState.error?.toString() ?? 'Failed to upload image',
      ));
      return false;
    }
  }

  /// Save as draft
  Future<void> saveDraft(
      {required String authorId, required String authorName}) async {
    if (!state.isValidForDraft) {
      emit(state.copyWith(
        errorMessage: 'Please enter a title',
        status: ArticleEditorStatus.error,
      ));
      return;
    }

    emit(state.copyWith(status: ArticleEditorStatus.saving));

    // Upload image first if there's a local image
    if (state.localImagePath != null) {
      final uploadSuccess = await uploadCoverImage();
      if (!uploadSuccess) {
        // Upload failed, error already emitted
        return;
      }
    }

    // Get the image URL after potential upload
    final imageUrl = state.coverImageUrl;

    final article = UserArticleEntity(
      id: state.id ?? '',
      authorId: authorId,
      authorName: authorName,
      title: state.title,
      content: state.content,
      thumbnailUrl: imageUrl,
      categories: state.categories,
      isDraft: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    DataState<UserArticleEntity> dataState;

    if (state.isEditing && state.id != null) {
      dataState = await _updateArticleUseCase(params: article);
    } else {
      dataState = await _createArticleUseCase(params: article);
    }

    if (dataState is DataSuccess && dataState.data != null) {
      emit(state.copyWith(
        id: dataState.data!.id,
        status: ArticleEditorStatus.success,
        successMessage: 'Draft saved successfully',
        isEditing: true,
        lastSaved: DateTime.now(),
      ));
    } else {
      emit(state.copyWith(
        status: ArticleEditorStatus.error,
        errorMessage: dataState.error?.toString() ?? 'Failed to save draft',
      ));
    }
  }

  /// Publish the article
  Future<void> publishArticle(
      {required String authorId, required String authorName}) async {
    if (!state.isValidForPublish) {
      emit(state.copyWith(
        errorMessage: 'Please fill in both title and content',
        status: ArticleEditorStatus.error,
      ));
      return;
    }

    emit(state.copyWith(status: ArticleEditorStatus.publishing));

    // Upload image first if there's a local image
    if (state.localImagePath != null) {
      final uploadSuccess = await uploadCoverImage();
      if (!uploadSuccess) {
        // Upload failed, error already emitted
        return;
      }
    }

    // Get the image URL after potential upload
    final imageUrl = state.coverImageUrl;

    // First, create or update the article
    final article = UserArticleEntity(
      id: state.id ?? '',
      authorId: authorId,
      authorName: authorName,
      title: state.title,
      content: state.content,
      thumbnailUrl: imageUrl,
      categories: state.categories,
      isDraft: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );

    DataState<UserArticleEntity> dataState;

    if (state.isEditing && state.id != null) {
      // Update then publish
      await _updateArticleUseCase(params: article);
      dataState = await _publishArticleUseCase(params: state.id!);
    } else {
      // Create as published
      dataState =
          await _createArticleUseCase(params: article.copyWith(isDraft: false));
    }

    if (dataState is DataSuccess && dataState.data != null) {
      emit(state.copyWith(
        id: dataState.data!.id,
        status: ArticleEditorStatus.success,
        successMessage: 'Article published successfully!',
        isDraft: false,
        lastSaved: DateTime.now(),
      ));
    } else {
      emit(state.copyWith(
        status: ArticleEditorStatus.error,
        errorMessage:
            dataState.error?.toString() ?? 'Failed to publish article',
      ));
    }
  }

  /// Clear any error messages
  void clearError() {
    emit(state.copyWith(clearError: true, status: ArticleEditorStatus.editing));
  }

  /// Clear any success messages
  void clearSuccess() {
    emit(state.copyWith(
        clearSuccess: true, status: ArticleEditorStatus.editing));
  }

  /// Reset the editor
  void reset() {
    emit(const ArticleEditorState());
  }
}
