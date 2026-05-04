import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/get_draft_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';
import 'upload_article_event.dart';
import 'upload_article_state.dart';

class UploadArticleBloc extends Bloc<UploadArticleEvent, UploadArticleState> {
  final PublishArticleUseCase _publishUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final ImageProcessingService _imageService;
  final FirebaseAuth _firebaseAuth;
  final GetDraftByIdUseCase _getDraftByIdUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;

  Timer? _debounceTimer;

  UploadArticleBloc(
    this._publishUseCase,
    this._saveDraftUseCase,
    this._imageService,
    this._firebaseAuth,
    this._getDraftByIdUseCase,
    this._updateArticleUseCase,
  ) : super(const UploadArticleState()) {
    on<StartNewArticleEvent>((_, emit) => emit(const UploadArticleState()));
    on<ResetEvent>((_, emit) => emit(const UploadArticleState()));
    on<LoadDraftEvent>(_onLoadDraft);
    on<LoadArticleForEditEvent>(_onLoadArticleForEdit);
    on<PickThumbnailEvent>(_onPickThumbnail);
    on<TitleChangedEvent>(
        (e, emit) => _emitWithDebounce(emit, state.copyWith(title: e.value)));
    on<DescriptionChangedEvent>((e, emit) =>
        _emitWithDebounce(emit, state.copyWith(description: e.value)));
    on<ContentChangedEvent>((e, emit) =>
        _emitWithDebounce(emit, state.copyWith(content: e.value)));
    on<CategoryChangedEvent>(
        (e, emit) => emit(state.copyWith(category: e.category)));
    on<TagsChangedEvent>((e, emit) => emit(state.copyWith(tags: e.tags)));
    on<LanguageChangedEvent>(
        (e, emit) => emit(state.copyWith(language: e.language)));
    on<LocationToggleEvent>(
        (e, emit) => emit(state.copyWith(location: e.location)));
    on<SaveDraftManuallyEvent>(_onSaveDraft);
    on<AutoSaveDraftTickEvent>(_onSaveDraft);
    on<PublishEvent>(_onPublish);
  }

  void _emitWithDebounce(
      Emitter<UploadArticleState> emit, UploadArticleState newState) {
    emit(newState);
    _debounceTimer?.cancel();
    // Auto-save drafts only in create mode. In edit mode a real article exists
    // already; an auto-saved "draft" would be a confusing duplicate.
    if (newState.editingArticleId != null) return;
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      add(const AutoSaveDraftTickEvent());
    });
  }

  Future<void> _onPickThumbnail(
    PickThumbnailEvent event,
    Emitter<UploadArticleState> emit,
  ) async {
    emit(state.copyWith(isPickingImage: true, error: null));
    final file = await _imageService.pickImage(source: event.source);
    if (file == null) {
      emit(state.copyWith(isPickingImage: false));
      return;
    }
    final cropped = await _imageService.cropToSixteenNine(file.path);
    if (cropped == null) {
      emit(state.copyWith(isPickingImage: false));
      return;
    }
    final bytes = await _imageService.compressForUpload(cropped.path);
    emit(state.copyWith(
      isPickingImage: false,
      localImagePath: cropped.path,
      compressedBytes: bytes,
    ));
  }

  Future<void> _onLoadArticleForEdit(
    LoadArticleForEditEvent event,
    Emitter<UploadArticleState> emit,
  ) async {
    final a = event.article;
    emit(UploadArticleState(
      editingArticleId: a.id,
      existingThumbnailUrl: a.urlToImage,
      title: a.title,
      description: a.description,
      content: a.content,
      localImagePath: null,
      compressedBytes: null,
      category: a.category,
      tags: a.tags,
      language: a.language,
      location: a.location,
    ));
  }

  Future<void> _onLoadDraft(
    LoadDraftEvent event,
    Emitter<UploadArticleState> emit,
  ) async {
    final result = await _getDraftByIdUseCase.call(
      params: DraftIdParams(draftId: event.draftId),
    );
    if (result is DataSuccess<DraftArticleEntity?> && result.data != null) {
      final draft = result.data!;
      emit(UploadArticleState(
        draftId: draft.id == 0 ? null : draft.id,
        title: draft.title,
        description: draft.description,
        content: draft.content,
        localImagePath: draft.localImagePath,
        // compressedBytes stays null — re-pick thumbnail when continuing draft,
        // as the local path may not be readable across app restarts.
        category: draft.category,
        tags: draft.tags,
        language: draft.language,
        location: draft.location,
        lastSavedAt: draft.lastSavedAt,
      ));
    } else if (result is DataFailed<DraftArticleEntity?>) {
      emit(state.copyWith(error: result.error));
    }
  }

  Future<void> _onSaveDraft(
    UploadArticleEvent event,
    Emitter<UploadArticleState> emit,
  ) async {
    if (state.title.isEmpty &&
        state.description.isEmpty &&
        state.content.isEmpty) {
      return;
    }
    final params = SaveDraftParams(
      id: state.draftId,
      title: state.title,
      description: state.description,
      content: state.content,
      localImagePath: state.localImagePath,
      category: state.category,
      tags: state.tags,
      language: state.language,
      location: state.location,
    );
    final result = await _saveDraftUseCase.call(params: params);
    if (result is DataSuccess<int>) {
      emit(state.copyWith(
        draftId: result.data,
        lastSavedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _onPublish(
    PublishEvent event,
    Emitter<UploadArticleState> emit,
  ) async {
    final validationError = _firstValidationError();
    if (validationError != null) {
      emit(state.copyWith(error: validationError));
      return;
    }

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      emit(state.copyWith(
        error: const AuthException(
          message: 'You must be signed in to publish.',
          code: 'unauthenticated',
        ),
      ));
      return;
    }

    emit(state.copyWith(isPublishing: true, error: null));

    if (state.editingArticleId != null) {
      final params = UpdateArticleParams(
        articleId: state.editingArticleId!,
        title: state.title,
        description: state.description,
        content: state.content,
        category: state.category!,
        tags: state.tags,
        language: state.language,
        location: state.location,
        newImageBytes: state.compressedBytes,
      );
      final result = await _updateArticleUseCase.call(params: params);
      if (result is DataSuccess<JournalistArticleEntity>) {
        emit(state.copyWith(isPublishing: false, isPublished: true));
      } else if (result is DataFailed<JournalistArticleEntity>) {
        emit(state.copyWith(isPublishing: false, error: result.error));
      }
      return;
    }

    final params = PublishArticleParams(
      title: state.title,
      description: state.description,
      content: state.content,
      imageBytes: state.compressedBytes!,
      userId: currentUser.uid,
      userDisplayName: currentUser.displayName ?? '',
      userPhotoUrl: currentUser.photoURL,
      category: state.category!,
      tags: state.tags,
      language: state.language,
      location: state.location,
      draftId: state.draftId,
    );

    final result = await _publishUseCase.call(params: params);
    if (result is DataSuccess<JournalistArticleEntity>) {
      emit(state.copyWith(isPublishing: false, isPublished: true));
    } else if (result is DataFailed<JournalistArticleEntity>) {
      emit(state.copyWith(isPublishing: false, error: result.error));
    }
  }

  ValidationException? _firstValidationError() {
    if (state.title.length < 5) {
      return const ValidationException(
        message: 'Title needs at least 5 characters.',
        code: 'title-too-short',
      );
    }
    if (state.title.length > 200) {
      return const ValidationException(
        message: 'Title is too long (max 200 characters).',
        code: 'title-too-long',
      );
    }
    if (state.description.length < 20) {
      return const ValidationException(
        message: 'Description needs at least 20 characters.',
        code: 'description-too-short',
      );
    }
    if (state.description.length > 500) {
      return const ValidationException(
        message: 'Description is too long (max 500 characters).',
        code: 'description-too-long',
      );
    }
    if (state.content.length < 50) {
      return const ValidationException(
        message: 'Content needs at least 50 characters.',
        code: 'content-too-short',
      );
    }
    if (state.editingArticleId == null && state.compressedBytes == null) {
      return const ValidationException(
        message: 'A thumbnail image is required.',
        code: 'thumbnail-required',
      );
    }
    if (state.category == null) {
      return const ValidationException(
        message: 'Please pick a category.',
        code: 'category-required',
      );
    }
    if (state.tags.isEmpty) {
      return const ValidationException(
        message: 'Add at least one tag.',
        code: 'tags-required',
      );
    }
    return null;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
