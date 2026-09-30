import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/article_draft.dart';
import '../../../domain/entities/invalid_article_draft_exception.dart';
import '../../../domain/use_cases/discard_draft.dart';
import '../../../domain/use_cases/pick_thumbnail_from_gallery.dart';
import '../../../domain/use_cases/publish_article.dart';
import '../../../domain/use_cases/resume_draft.dart';
import '../../../domain/use_cases/save_draft.dart';
import 'publish_article_state.dart';

class PublishArticleCubit extends Cubit<PublishArticleState> {
  /// Pause in the typing after which the draft is saved on the device.
  static const Duration draftSavingDelay = Duration(seconds: 1);

  final PublishArticleUseCase _publishArticleUseCase;
  final PickThumbnailFromGalleryUseCase _pickThumbnailFromGalleryUseCase;
  final ResumeDraftUseCase _resumeDraftUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final DiscardDraftUseCase _discardDraftUseCase;

  Timer? _pendingDraftSave;
  Future<void>? _draftBeingSaved;

  PublishArticleCubit(
    this._publishArticleUseCase,
    this._pickThumbnailFromGalleryUseCase,
    this._resumeDraftUseCase,
    this._saveDraftUseCase,
    this._discardDraftUseCase,
  ) : super(const PublishArticleEditing(ArticleDraftEntity()));

  /// Continues the draft left unfinished, or starts a new one signed like the previous article.
  /// Does nothing if the journalist already started typing.
  Future<void> resumeDraft() async {
    final draft = (await _resumeDraftUseCase()).data;
    if (draft == null || isClosed || state.draft != const ArticleDraftEntity()) return;
    emit(PublishArticleDraftLoaded(draft, isRestored: !draft.isBlank));
  }

  /// Throws the restored draft away and starts a new one, keeping the signature.
  Future<void> startOver() async {
    if (state is PublishArticlePublishing) return;
    await discardDraft();
    if (isClosed) return;
    emit(PublishArticleDraftLoaded(ArticleDraftEntity(author: state.draft.author), isRestored: false));
  }

  /// Deletes the saved draft, including any change not saved yet.
  Future<void> discardDraft() async {
    _pendingDraftSave?.cancel();
    await _draftBeingSaved;
    await _discardDraftUseCase();
  }

  void changeTitle(String title) => _updateDraft(state.draft.withTitle(title));

  void changeContent(String content) => _updateDraft(state.draft.withContent(content));

  void changeAuthor(String author) => _updateDraft(state.draft.withAuthor(author));

  Future<void> pickThumbnail() async {
    final result = await _pickThumbnailFromGalleryUseCase();
    if (result is DataFailed) {
      emit(PublishArticleFailure(state.draft, PublishArticleFailureReason.galleryUnavailable));
      return;
    }
    final thumbnail = result.data;
    if (thumbnail != null) _updateDraft(state.draft.withThumbnail(thumbnail));
  }

  Future<void> publish() async {
    if (state is PublishArticlePublishing || state is PublishArticleSuccess) return;
    final errors = state.draft.trimmed().errors;
    if (errors.isNotEmpty) {
      emit(PublishArticleInvalid(state.draft, errors));
      return;
    }
    emit(PublishArticlePublishing(state.draft));
    // Saved first: if publishing fails, the draft survives; once published, it is deleted.
    await _saveDraftNow();
    _emitPublishResult(await _publishArticleUseCase(params: state.draft));
  }

  /// Leaving the form saves the latest changes.
  @override
  Future<void> close() async {
    await _saveDraftNow();
    return super.close();
  }

  void _emitPublishResult(DataState<void> result) {
    final error = result.error;
    if (error == null) {
      emit(PublishArticleSuccess(state.draft));
    } else if (error is InvalidArticleDraftException) {
      emit(PublishArticleInvalid(state.draft, error.errors));
    } else {
      emit(PublishArticleFailure(state.draft, PublishArticleFailureReason.publishFailed));
    }
  }

  void _updateDraft(ArticleDraftEntity draft) {
    if (state is PublishArticlePublishing) return;
    _emitEdited(draft);
    _pendingDraftSave?.cancel();
    _pendingDraftSave = Timer(draftSavingDelay, _saveDraft);
  }

  void _emitEdited(ArticleDraftEntity draft) {
    if (state is! PublishArticleInvalid) {
      emit(PublishArticleEditing(draft));
      return;
    }
    final errors = draft.trimmed().errors;
    emit(errors.isEmpty ? PublishArticleEditing(draft) : PublishArticleInvalid(draft, errors));
  }

  /// Saves right away the changes still waiting for [draftSavingDelay].
  Future<void> _saveDraftNow() async {
    if (_pendingDraftSave?.isActive ?? false) {
      _pendingDraftSave!.cancel();
      _saveDraft();
    }
    await _draftBeingSaved;
  }

  /// Saves one draft at a time, so an older draft never overwrites a newer one.
  void _saveDraft() {
    final draft = state.draft;
    final previousSave = _draftBeingSaved ?? Future<void>.value();
    _draftBeingSaved = previousSave.then((_) => _saveDraftUseCase(params: draft));
  }
}
