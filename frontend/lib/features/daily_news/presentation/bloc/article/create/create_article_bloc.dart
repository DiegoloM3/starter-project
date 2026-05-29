import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/utils/bloc_transformers.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/utils/reading_time_calculator.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';

class CreateArticleBloc
    extends Bloc<CreateArticleEvent, CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final UploadThumbnailUseCase _uploadThumbnailUseCase;
  final String authorId;
  final String authorName;

  // Shared in-flight futures so a racing autosave + save/publish don't create
  // the article or upload the thumbnail twice. They never emit — the awaiting
  // handler owns the emit, so a cancelled handler can't emit after completing.
  Future<DataState<ArticleEntity>>? _pendingCreate;
  Future<DataState<String>>? _pendingUpload;

  CreateArticleBloc(
    this._createArticleUseCase,
    this._updateArticleUseCase,
    this._uploadThumbnailUseCase, {
    required this.authorId,
    required this.authorName,
  }) : super(const CreateArticleState()) {
    on<ExistingDraftLoaded>(_onLoadDraft);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<ContentChanged>(_onContentChanged);
    on<ThumbnailSelected>(_onThumbnailSelected);
    on<ThumbnailRemoved>(_onThumbnailRemoved);
    on<AutosaveRequested>(
      _onAutosave,
      transformer: debounceRestartable(const Duration(seconds: 2)),
    );
    on<DraftSaveRequested>(_onSaveDraft);
    on<PublishRequested>(_onPublish);
    on<ArchiveRequested>(_onArchive);
  }

  void _onLoadDraft(
    ExistingDraftLoaded event,
    Emitter<CreateArticleState> emit,
  ) {
    final article = event.article;
    emit(state.copyWith(
      articleId: article.id,
      title: article.title ?? '',
      description: article.description ?? '',
      content: article.content ?? '',
      thumbnailUrl: article.thumbnailUrl,
      thumbnailPath: article.thumbnailPath,
      status: article.status ?? ArticleStatus.draft,
      readingTimeMinutes: article.readingTimeMinutes ?? 1,
      clearError: true,
    ));
  }

  void _onTitleChanged(
    TitleChanged event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(state.copyWith(title: event.title, clearError: true));
    add(const AutosaveRequested());
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(state.copyWith(description: event.description, clearError: true));
    add(const AutosaveRequested());
  }

  void _onContentChanged(
    ContentChanged event,
    Emitter<CreateArticleState> emit,
  ) {
    final readingTime = ReadingTimeCalculator.calculate(event.content);
    emit(state.copyWith(
      content: event.content,
      readingTimeMinutes: readingTime,
      clearError: true,
    ));
    add(const AutosaveRequested());
  }

  void _onThumbnailSelected(
    ThumbnailSelected event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(state.copyWith(selectedImagePath: event.filePath, clearError: true));
    add(const AutosaveRequested());
  }

  void _onThumbnailRemoved(
    ThumbnailRemoved event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedImage: true,
      clearThumbnailUrl: true,
      clearError: true,
    ));
    add(const AutosaveRequested());
  }

  Future<void> _onAutosave(
    AutosaveRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (!state.hasContent) return;
    await _performSave(emit);
  }

  Future<void> _onSaveDraft(
    DraftSaveRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (!state.hasContent) return;
    await _performSave(emit);
  }

  Future<void> _performSave(Emitter<CreateArticleState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    if (state.articleId == null) {
      final created = await _createNewArticle();
      if (created is DataFailed) {
        emit(state.copyWith(isSaving: false, error: created.error));
        return;
      }
      emit(state.copyWith(articleId: created.data!.id));
    } else {
      final updated = await _updateExistingArticle();
      if (updated is DataFailed) {
        emit(state.copyWith(isSaving: false, error: updated.error));
        return;
      }
    }

    // Upload thumbnail if selected but not yet uploaded
    if (state.selectedImagePath != null &&
        state.thumbnailUrl == null &&
        state.articleId != null) {
      final uploaded = await _uploadThumbnail();
      if (uploaded is DataFailed) {
        emit(state.copyWith(isSaving: false, error: uploaded.error));
        return;
      }
      emit(state.copyWith(thumbnailUrl: uploaded.data));

      final persisted = await _updateExistingArticle();
      if (persisted is DataFailed) {
        emit(state.copyWith(isSaving: false, error: persisted.error));
        return;
      }
    }

    emit(state.copyWith(isSaving: false, lastSavedAt: DateTime.now()));
  }

  Future<void> _onPublish(
    PublishRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (!state.canPublish) return;

    if (!ArticleStatus.isValidTransition(
      state.status,
      ArticleStatus.published,
    )) {
      return;
    }

    emit(state.copyWith(isPublishing: true, clearError: true));

    // Ensure the article exists
    if (state.articleId == null) {
      final created = await _createNewArticle();
      if (created is DataFailed) {
        emit(state.copyWith(isPublishing: false, error: created.error));
        return;
      }
      emit(state.copyWith(articleId: created.data!.id));
    }

    // Upload thumbnail if selected but not yet uploaded
    if (state.selectedImagePath != null && state.thumbnailUrl == null) {
      final uploaded = await _uploadThumbnail();
      if (uploaded is DataFailed) {
        emit(state.copyWith(isPublishing: false, error: uploaded.error));
        return;
      }
      emit(state.copyWith(thumbnailUrl: uploaded.data));
    }

    // Transition to published. The same update persists the thumbnail URL
    // (read from state), so no separate write is needed.
    final entity = state
        .toEntity(authorId: authorId, authorName: authorName)
        .copyWith(
          status: ArticleStatus.published,
          publishedAt: DateTime.now().toIso8601String(),
        );

    final result = await _updateArticleUseCase(params: entity);
    if (result is DataFailed) {
      emit(state.copyWith(isPublishing: false, error: result.error));
      return;
    }

    emit(state.copyWith(
      isPublishing: false,
      isPublished: true,
      status: ArticleStatus.published,
    ));
  }

  Future<void> _onArchive(
    ArchiveRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (!state.canArchive) return;

    if (!ArticleStatus.isValidTransition(
      state.status,
      ArticleStatus.archived,
    )) {
      return;
    }

    emit(state.copyWith(isPublishing: true, clearError: true));

    final entity = state
        .toEntity(authorId: authorId, authorName: authorName)
        .copyWith(status: ArticleStatus.archived);

    final result = await _updateArticleUseCase(params: entity);
    if (result is DataFailed) {
      emit(state.copyWith(isPublishing: false, error: result.error));
      return;
    }

    emit(state.copyWith(
      isPublishing: false,
      status: ArticleStatus.archived,
    ));
  }

  // --- Private helpers (return results, never emit) ---

  Future<DataState<ArticleEntity>> _createNewArticle() async {
    if (_pendingCreate != null) return _pendingCreate!;
    _pendingCreate = _doCreateNewArticle();
    try {
      return await _pendingCreate!;
    } finally {
      _pendingCreate = null;
    }
  }

  Future<DataState<ArticleEntity>> _doCreateNewArticle() {
    final entity = state.toEntity(authorId: authorId, authorName: authorName);
    return _createArticleUseCase(params: entity);
  }

  Future<DataState<ArticleEntity>> _updateExistingArticle() {
    final entity = state.toEntity(authorId: authorId, authorName: authorName);
    return _updateArticleUseCase(params: entity);
  }

  Future<DataState<String>> _uploadThumbnail() async {
    if (_pendingUpload != null) return _pendingUpload!;
    _pendingUpload = _doUploadThumbnail();
    try {
      return await _pendingUpload!;
    } finally {
      _pendingUpload = null;
    }
  }

  Future<DataState<String>> _doUploadThumbnail() async {
    try {
      return await _uploadThumbnailUseCase(
        params: UploadThumbnailParams(
          articleId: state.articleId!,
          filePath: state.selectedImagePath!,
        ),
      ).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      return const DataFailed<String>(
        AppException(message: 'Image upload timed out', code: 'timeout'),
      );
    }
  }
}
