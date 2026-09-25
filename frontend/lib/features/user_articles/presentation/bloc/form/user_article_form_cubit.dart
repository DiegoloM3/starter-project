import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/create_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_user_article_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';

import 'article_form_input.dart';
import 'user_article_form_state.dart';

/// One editing session of one article -- a brand-new one, or an existing
/// one handed to [edit]. Besides the explicit saves (whose states drive the
/// screen's overlay and close it), it owns autosave: whether the article
/// exists on the server yet, never letting two writes race, uploading a
/// photo only once, and undoing a session's autosaves on discard. None of
/// that ordering lives in the widget.
class UserArticleFormCubit extends Cubit<UserArticleFormState> {
  final CreateUserArticleUseCase _createUserArticleUseCase;
  final UpdateUserArticleUseCase _updateUserArticleUseCase;
  final DeleteUserArticleUseCase _deleteUserArticleUseCase;
  final GetCurrentAccountUseCase _getCurrentAccountUseCase;

  UserArticleEntity? _original;

  /// Null until a new article is first written; from then on every write
  /// updates that same document.
  String? _articleId;

  /// The photo already uploaded in this session, so later saves don't send
  /// the same bytes again.
  Uint8List? _uploadedImage;

  bool _autosavedThisSession = false;
  Future<UserArticleEntity?>? _autosaveInFlight;

  UserArticleFormCubit(
    this._createUserArticleUseCase,
    this._updateUserArticleUseCase,
    this._deleteUserArticleUseCase,
    this._getCurrentAccountUseCase,
  ) : super(const UserArticleFormIdle());

  /// Starts the session on [article], or on a brand-new one when null.
  void edit(UserArticleEntity? article) {
    _original = article;
    _articleId = article?.id;
  }

  /// Whether autosave uploads a newly picked photo -- only for a new
  /// article. On an existing draft the photo waits for an explicit save, so
  /// discarding the session can still restore that draft exactly: a text
  /// field can be written back, a replaced file can't.
  bool get autosavesImage => _original == null;

  /// The byline to offer a new article, from the connected account's name
  /// -- null for a guest, or one with no display name (email accounts,
  /// mainly), in which case the field just starts empty as it always did.
  Future<String?> suggestedAuthorName() async {
    final result = await _getCurrentAccountUseCase();
    if (result is! DataSuccess<AccountEntity>) return null;
    final name = result.data!.displayName?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Persists [input] as a draft in the background. Never emits a state --
  /// those drive the full-screen overlay and close the screen, and neither
  /// should happen because a timer fired while someone is still writing.
  /// Skipped (null) while another write is on its way, so two creates can't
  /// race each other into two copies of one article; the caller simply
  /// tries again on its next tick. Also null when the write fails.
  Future<UserArticleEntity?> autosave(ArticleFormInput input) async {
    if (_autosaveInFlight != null || state is UserArticleFormSubmitting) {
      return null;
    }
    final write = _autosave(input);
    _autosaveInFlight = write;
    try {
      return await write;
    } finally {
      _autosaveInFlight = null;
    }
  }

  Future<UserArticleEntity?> _autosave(ArticleFormInput input) async {
    final result = await _write(
      autosavesImage ? input : input.withoutImage(),
      isDraft: true,
    );
    if (result is! DataSuccess<UserArticleEntity>) return null;
    _autosavedThisSession = true;
    return result.data;
  }

  Future<void> saveDraft(ArticleFormInput input) =>
      _submit(input, isDraft: true);

  Future<void> publish(ArticleFormInput input) =>
      _submit(input, isDraft: false);

  Future<void> _submit(ArticleFormInput input, {required bool isDraft}) async {
    emit(const UserArticleFormSubmitting());
    // An autosave already on its way may be creating this very article:
    // waiting for it makes this write update that article, instead of
    // creating a second one next to it.
    await _autosaveInFlight;
    final result = await _write(input, isDraft: isDraft);
    if (result is DataSuccess<UserArticleEntity>) {
      emit(UserArticleFormSuccess(result.data!));
    } else {
      emit(UserArticleFormError(
          result.error?.toString() ?? 'Could not save article'));
    }
  }

  /// Undoes whatever autosave wrote during this session. A new article
  /// that only exists because of autosave is deleted; an existing draft is
  /// written back exactly as it was when the session started. Nothing to
  /// undo when autosave never wrote.
  Future<void> discardChanges() async {
    await _autosaveInFlight;
    final id = _articleId;
    if (!_autosavedThisSession || id == null) return;
    final original = _original;
    if (original == null) {
      await _deleteUserArticleUseCase(params: id);
      _articleId = null;
    } else {
      await _write(
        ArticleFormInput.fromArticle(original),
        isDraft: original.isDraft,
      );
    }
    _autosavedThisSession = false;
  }

  Future<DataState<UserArticleEntity>> _write(
    ArticleFormInput input, {
    required bool isDraft,
  }) async {
    final newImage =
        identical(input.imageBytes, _uploadedImage) ? null : input.imageBytes;
    final newImageExtension = newImage == null ? null : input.imageExtension;
    final id = _articleId;
    final result = id == null
        ? await _createUserArticleUseCase(
            params: CreateUserArticleParams(
              authorName: input.authorName,
              title: input.title,
              description: input.description,
              content: input.content,
              thumbnailBytes: newImage,
              thumbnailExtension: newImageExtension,
              isDraft: isDraft,
            ),
          )
        : await _updateUserArticleUseCase(
            params: UpdateUserArticleParams(
              id: id,
              authorName: input.authorName,
              title: input.title,
              description: input.description,
              content: input.content,
              newThumbnailBytes: newImage,
              newThumbnailExtension: newImageExtension,
              isDraft: isDraft,
            ),
          );
    if (result is DataSuccess<UserArticleEntity>) {
      _articleId = result.data!.id;
      if (newImage != null) _uploadedImage = newImage;
    }
    return result;
  }
}
