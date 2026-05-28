import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/utils/bloc_transformers.dart';
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

  CreateArticleBloc(
    this._createArticleUseCase,
    this._updateArticleUseCase,
    this._uploadThumbnailUseCase, {
    required this.authorId,
    required this.authorName,
  }) : super(const CreateArticleState()) {
    on<LoadExistingDraft>(_onLoadDraft);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<ContentChanged>(_onContentChanged);
    on<ThumbnailSelected>(_onThumbnailSelected);
    on<ThumbnailRemoved>(_onThumbnailRemoved);
    on<AutosaveRequested>(
      _onAutosave,
      transformer: debounceRestartable(const Duration(seconds: 2)),
    );
    on<SaveDraft>(_onSaveDraft);
    on<PublishArticle>(_onPublish);
    on<ArchiveArticle>(_onArchive);
  }

  void _onLoadDraft(
    LoadExistingDraft event,
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
    SaveDraft event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (!state.hasContent) return;
    await _performSave(emit);
  }

  Future<void> _onPublish(
    PublishArticle event,
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

    // Ensure article is saved first
    if (state.articleId == null) {
      final saved = await _createNewArticle(emit);
      if (!saved) {
        emit(state.copyWith(isPublishing: false));
        return;
      }
    }

    // Upload thumbnail if selected but not yet uploaded
    if (state.selectedImagePath != null && state.thumbnailUrl == null) {
      final uploaded = await _uploadPendingThumbnail(emit);
      if (!uploaded) {
        emit(state.copyWith(isPublishing: false));
        return;
      }
    }

    // Transition to published
    final publishedAt = DateTime.now().toIso8601String();
    final entity = state.toEntity(
      authorId: authorId,
      authorName: authorName,
    ).copyWith(
      status: ArticleStatus.published,
      publishedAt: publishedAt,
    );

    final result = await _updateArticleUseCase(params: entity);

    if (result is DataFailed) {
      emit(state.copyWith(
        isPublishing: false,
        error: result.error,
      ));
      return;
    }

    emit(state.copyWith(
      isPublishing: false,
      isPublished: true,
      status: ArticleStatus.published,
    ));
  }

  Future<void> _onArchive(
    ArchiveArticle event,
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

    final entity = state.toEntity(
      authorId: authorId,
      authorName: authorName,
    ).copyWith(status: ArticleStatus.archived);

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

  // --- Private helpers ---

  Future<void> _performSave(Emitter<CreateArticleState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    if (state.articleId == null) {
      await _createNewArticle(emit);
    } else {
      await _updateExistingArticle(emit);
    }

    // Upload thumbnail if selected but not yet uploaded
    if (state.selectedImagePath != null &&
        state.thumbnailUrl == null &&
        state.articleId != null) {
      await _uploadPendingThumbnail(emit);
    }

    emit(state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
    ));
  }

  Future<bool> _createNewArticle(Emitter<CreateArticleState> emit) async {
    final entity = state.toEntity(
      authorId: authorId,
      authorName: authorName,
    );

    final result = await _createArticleUseCase(params: entity);

    if (result is DataFailed) {
      emit(state.copyWith(isSaving: false, error: result.error));
      return false;
    }

    final created = result.data!;
    emit(state.copyWith(articleId: created.id));
    return true;
  }

  Future<bool> _updateExistingArticle(
    Emitter<CreateArticleState> emit,
  ) async {
    final entity = state.toEntity(
      authorId: authorId,
      authorName: authorName,
    );

    final result = await _updateArticleUseCase(params: entity);

    if (result is DataFailed) {
      emit(state.copyWith(isSaving: false, error: result.error));
      return false;
    }

    return true;
  }

  Future<bool> _uploadPendingThumbnail(
    Emitter<CreateArticleState> emit,
  ) async {
    final uploadResult = await _uploadThumbnailUseCase(
      params: UploadThumbnailParams(
        articleId: state.articleId!,
        filePath: state.selectedImagePath!,
      ),
    );

    if (uploadResult is DataFailed) {
      emit(state.copyWith(error: uploadResult.error));
      return false;
    }

    emit(state.copyWith(thumbnailUrl: uploadResult.data));

    // Update article with thumbnail URL
    final entity = state.toEntity(
      authorId: authorId,
      authorName: authorName,
    ).copyWith(thumbnailUrl: uploadResult.data);

    await _updateArticleUseCase(params: entity);
    return true;
  }
}
