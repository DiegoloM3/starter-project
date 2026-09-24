import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../../../domain/entities/article_failures.dart';
import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/article_thumbnail.dart';
import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/create_article_params.dart';
import '../../../domain/params/get_article_by_id_params.dart';
import '../../../domain/params/publish_article_params.dart';
import '../../../domain/params/update_article_params.dart';
import '../../../domain/params/upload_article_thumbnail_params.dart';
import '../../../domain/use_cases/create_article.dart';
import '../../../domain/use_cases/get_article_by_id.dart';
import '../../../domain/use_cases/pick_article_cover.dart';
import '../../../domain/use_cases/publish_article.dart';
import '../../../domain/use_cases/update_article.dart';
import '../../../domain/use_cases/upload_article_thumbnail.dart';
import 'article_editor_state.dart';

/// Drives the screen where a journalist writes a new article or edits one of
/// their stored ones.
///
/// Whether an article may be saved as a draft or published is decided by the
/// use cases; the cubit only reports what they answered.
class ArticleEditorCubit extends Cubit<ArticleEditorState> {
  final GetArticleByIdUseCase _getArticleById;
  final CreateArticleUseCase _createArticle;
  final UpdateArticleUseCase _updateArticle;
  final PublishArticleUseCase _publishArticle;
  final UploadArticleThumbnailUseCase _uploadThumbnail;
  final PickArticleCoverUseCase _pickArticleCover;

  final String journalistId;
  final String journalistName;

  /// How long to wait after the last edit before autosaving a draft.
  final Duration autosaveDelay;

  Timer? _autosaveTimer;

  ArticleEditorCubit(
    this._getArticleById,
    this._createArticle,
    this._updateArticle,
    this._publishArticle,
    this._uploadThumbnail,
    this._pickArticleCover, {
    required this.journalistId,
    required this.journalistName,
    this.autosaveDelay = const Duration(seconds: 2),
  }) : super(const ArticleEditorState());

  /// Prepares the editor for an article that does not exist yet.
  void startNewArticle() {
    emit(ArticleEditorState(
      article: JournalistArticleEntity(
        author: journalistName,
        userId: journalistId,
      ),
    ));
  }

  /// Loads a stored article so the journalist can keep working on it.
  Future<void> loadArticle(String articleId) async {
    emit(state.copyWith(status: ArticleEditorStatus.loading, clearError: true));

    final result = await _getArticleById(GetArticleByIdParams(articleId));

    if (result is DataSuccess<JournalistArticleEntity>) {
      final loaded = result.data!;
      emit(ArticleEditorState(article: loaded, savedArticle: loaded));
      return;
    }

    emit(state.copyWith(
      status: ArticleEditorStatus.failure,
      error: result.error,
    ));
  }

  void titleChanged(String title) => _editArticle(title: title);

  void descriptionChanged(String description) =>
      _editArticle(description: description);

  void contentChanged(String content) => _editArticle(content: content);

  /// Asks for a cover image and, if one comes back, uploads it.
  ///
  /// Cancelling the gallery leaves the editor exactly as it was: somebody who
  /// opens it and changes their mind has not done anything that needs
  /// reporting.
  Future<void> pickCover() async {
    final picked = await _pickArticleCover(const NoParams());

    if (picked is! DataSuccess<ArticleThumbnailEntity?>) {
      _emitFailure(picked.error);
      return;
    }

    final thumbnail = picked.data;

    if (thumbnail == null) {
      return;
    }

    return uploadThumbnail(thumbnail);
  }

  /// Uploads the picked image and attaches its url to the article.
  Future<void> uploadThumbnail(ArticleThumbnailEntity thumbnail) async {
    emit(state.copyWith(
      status: ArticleEditorStatus.uploadingThumbnail,
      clearError: true,
      isSaving: true,
    ));

    final result = await _uploadThumbnail(
      UploadArticleThumbnailParams(
        userId: journalistId,
        thumbnail: thumbnail,
      ),
    );

    if (result is DataSuccess<String>) {
      emit(state.copyWith(
        status: ArticleEditorStatus.editing,
        article: state.article.copyWith(thumbnailUrl: result.data),
        isSaving: false,
      ));
      return;
    }

    _emitFailure(result.error);
  }

  /// Takes the cover back off the article.
  ///
  /// It only clears the link the article holds; the uploaded file is left in
  /// storage. Deleting it would be wrong here — the journalist may put it
  /// back, and an article that was already published still points at it until
  /// the change is saved.
  void removeThumbnail() {
    emit(state.copyWith(
      status: ArticleEditorStatus.editing,
      article: state.article.copyWith(thumbnailUrl: ''),
      clearError: true,
    ));
  }

  /// Saves whatever the journalist changed, because they asked for it. The
  /// editor closes afterwards.
  ///
  /// Not named for drafts any more: on a published article this stores the
  /// edits without taking it back out of the feed, which is the same action
  /// from the writer's point of view and a different one underneath.
  Future<void> save() => _save(automatic: false);

  Future<void> _save({required bool automatic}) async {
    // A save already running is left to finish. Without this an autosave that
    // fired a moment earlier and a tap on Save both created the same new
    // article, and the journalist ended up with two of it.
    if (state.isSaving) {
      return;
    }

    _autosaveTimer?.cancel();
    emit(state.copyWith(
      status: ArticleEditorStatus.saving,
      clearError: true,
      isSaving: true,
    ));

    final result = state.article.isStored
        ? await _updateArticle(UpdateArticleParams(state.article))
        : await _createArticle(_createParams(ArticleStatus.draft));

    _emitSaveResult(
      result,
      onSuccess:
          automatic ? ArticleEditorStatus.autosaved : ArticleEditorStatus.saved,
      keepTypedText: automatic,
    );
  }

  /// Saves the article and makes it readable by the audience.
  Future<void> publish() async {
    if (state.isSaving) {
      return;
    }

    _autosaveTimer?.cancel();
    emit(state.copyWith(
      status: ArticleEditorStatus.saving,
      clearError: true,
      isSaving: true,
    ));

    final result = state.article.isStored
        ? await _publishArticle(PublishArticleParams(state.article))
        : await _createArticle(_createParams(ArticleStatus.published));

    _emitSaveResult(
      result,
      onSuccess: ArticleEditorStatus.published,
      keepTypedText: false,
    );
  }

  void _editArticle({
    String? title,
    String? description,
    String? content,
  }) {
    emit(state.copyWith(
      status: ArticleEditorStatus.editing,
      article: state.article.copyWith(
        title: title,
        description: description,
        content: content,
      ),
      validationErrors: const [],
      clearError: true,
    ));
    _scheduleAutosave();
  }

  /// Debounces `save()` after an edit.
  ///
  /// Only schedules while the article is a draft that already satisfies the
  /// draft rules (title, author and owner set): editing an already published
  /// article never autosaves over the live version, and a brand new article
  /// is not saved on every keystroke before it even has a title.
  void _scheduleAutosave() {
    _autosaveTimer?.cancel();

    if (!state.article.isDraft || state.article.validateAsDraft().isNotEmpty) {
      return;
    }

    _autosaveTimer = Timer(autosaveDelay, () {
      if (!isClosed) {
        _save(automatic: true);
      }
    });
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }

  CreateArticleParams _createParams(ArticleStatus status) {
    return CreateArticleParams(
      title: state.article.title,
      description: state.article.description,
      content: state.article.content,
      author: journalistName,
      userId: journalistId,
      thumbnailUrl: state.article.thumbnailUrl,
      status: status,
    );
  }

  void _emitSaveResult(
    DataState<JournalistArticleEntity> result, {
    required ArticleEditorStatus onSuccess,
    required bool keepTypedText,
  }) {
    if (result is DataSuccess<JournalistArticleEntity>) {
      final stored = result.data!;

      emit(state.copyWith(
        status: onSuccess,
        isSaving: false,
        // What is now on the backend, so the editor can tell whether
        // anything typed since would be lost by leaving.
        savedArticle: stored,
        // An autosave runs while the journalist is still writing, and they may
        // have typed more while the write was in flight. Taking the whole
        // stored article back would overwrite those keystrokes with what the
        // backend received a moment ago, so only what the backend owns is
        // taken and the text on screen is left alone.
        article: keepTypedText
            ? state.article.copyWith(
                id: stored.id,
                createdAt: stored.createdAt,
                updatedAt: stored.updatedAt,
              )
            : stored,
        validationErrors: const [],
      ));
      return;
    }

    _emitFailure(result.error);
  }

  void _emitFailure(Object? error) {
    emit(state.copyWith(
      status: ArticleEditorStatus.failure,
      error: error,
      // Whatever went wrong, the write is over: leaving this set is what
      // left Save and Publish dead with no way back but discarding.
      isSaving: false,
      validationErrors: error is ArticleValidationException
          ? error.errors
          : const <ArticleValidationError>[],
    ));
  }
}
