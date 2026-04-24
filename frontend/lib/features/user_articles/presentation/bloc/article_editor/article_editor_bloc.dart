import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_event.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_state.dart';

/// Orchestrates the create/edit article form.
///
/// The bloc decides between [PublishArticleUseCase] and
/// [UpdateArticleUseCase] based on whether the initial state carries an
/// `editingId`. Thumbnails are uploaded inline right before submit — the
/// raw bytes live in the bloc state until then so the editor never needs
/// to talk to Storage directly.
class ArticleEditorBloc
    extends Bloc<ArticleEditorEvent, ArticleEditorState> {
  ArticleEditorBloc({
    required PublishArticleUseCase publishArticle,
    required UpdateArticleUseCase updateArticle,
    required UploadThumbnailUseCase uploadThumbnail,
    required AuthSession authSession,
    UserArticleEntity? editing,
  })  : _publishArticle = publishArticle,
        _updateArticle = updateArticle,
        _uploadThumbnail = uploadThumbnail,
        _authSession = authSession,
        super(
          editing == null
              ? ArticleEditorState.initial()
              : ArticleEditorState.fromArticle(editing),
        ) {
    on<ArticleEditorTitleChanged>(
      (e, emit) => emit(state.copyWith(title: e.value, failure: null)),
    );
    on<ArticleEditorDescriptionChanged>(
      (e, emit) => emit(state.copyWith(description: e.value, failure: null)),
    );
    on<ArticleEditorContentChanged>(
      (e, emit) => emit(state.copyWith(content: e.value, failure: null)),
    );
    on<ArticleEditorTagsChanged>(
      (e, emit) => emit(state.copyWith(tags: e.tags, failure: null)),
    );
    on<ArticleEditorThumbnailPicked>(_onThumbnailPicked);
    on<ArticleEditorSubmitted>(_onSubmitted);
  }

  final PublishArticleUseCase _publishArticle;
  final UpdateArticleUseCase _updateArticle;
  final UploadThumbnailUseCase _uploadThumbnail;
  final AuthSession _authSession;

  void _onThumbnailPicked(
    ArticleEditorThumbnailPicked event,
    Emitter<ArticleEditorState> emit,
  ) {
    // Stash the raw file on state; we postpone Storage upload to submit so
    // the user can re-pick without burning one request per tap.
    emit(
      state.copyWith(
        pendingFileName: event.fileName,
        pendingBytes: event.bytes,
        pendingContentType: event.contentType,
        // Show immediate feedback while they still have the previous URL.
        thumbnailURL: state.thumbnailURL.isEmpty
            ? 'pending://${event.fileName}'
            : state.thumbnailURL,
        failure: null,
      ),
    );
  }

  Future<void> _onSubmitted(
    ArticleEditorSubmitted event,
    Emitter<ArticleEditorState> emit,
  ) async {
    final user = _authSession.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: EditorStatus.failure,
          failure: const AppFailure.auth(message: 'not signed in'),
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditorStatus.submitting, failure: null));

    var thumbnailURL = state.thumbnailURL;
    if (state.hasPendingThumbnail) {
      final uploadResult = await _uploadThumbnail(
        UploadThumbnailParams(
          authorId: user.id,
          articleId: state.editingId ?? 'new',
          fileName: state.pendingFileName!,
          bytes: state.pendingBytes!,
          contentType: state.pendingContentType!,
        ),
      );
      final shouldReturn = uploadResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: EditorStatus.failure,
              failure: failure,
            ),
          );
          return true;
        },
        (url) {
          thumbnailURL = url;
          return false;
        },
      );
      if (shouldReturn) return;
    }

    if (state.isEditing) {
      final result = await _updateArticle(
        UpdateArticleParams(
          id: state.editingId!,
          title: state.title,
          description: state.description,
          content: state.content,
          thumbnailURL: thumbnailURL,
          tags: state.tags,
        ),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(status: EditorStatus.failure, failure: failure),
        ),
        (article) => emit(
          state.copyWith(
            status: EditorStatus.success,
            saved: article,
            thumbnailURL: thumbnailURL,
            pendingBytes: null,
            pendingFileName: null,
            pendingContentType: null,
          ),
        ),
      );
      return;
    }

    final result = await _publishArticle(
      PublishArticleParams(
        authorId: user.id,
        authorName: user.name,
        title: state.title,
        description: state.description,
        content: state.content,
        thumbnailURL: thumbnailURL,
        tags: state.tags,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: EditorStatus.failure, failure: failure),
      ),
      (article) => emit(
        state.copyWith(
          status: EditorStatus.success,
          saved: article,
          thumbnailURL: thumbnailURL,
          pendingBytes: null,
          pendingFileName: null,
          pendingContentType: null,
        ),
      ),
    );
  }
}
