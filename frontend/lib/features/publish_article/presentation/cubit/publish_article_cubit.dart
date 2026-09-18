import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/params/publish_article_params.dart';
import '../../domain/use_cases/publish_article_result.dart';
import '../../domain/use_cases/publish_article_use_case.dart';
import 'publish_article_state.dart';

class PublishArticleCubit extends Cubit<PublishArticleState> {
  final PublishArticleUseCase _publishArticleUseCase;

  PublishArticleCubit(this._publishArticleUseCase)
      : super(PublishArticleState());

  void authorChanged(String value) {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        author: value,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.author,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  void titleChanged(String value) {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        title: value,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.title,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  void descriptionChanged(String value) {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        description: value,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.description,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  void contentChanged(String value) {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        content: value,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.content,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  void thumbnailSelected(ArticleThumbnail thumbnail) {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        thumbnail: thumbnail,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.thumbnailFileName,
          PublishArticleField.thumbnailMimeType,
          PublishArticleField.thumbnailBytes,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  void thumbnailRemoved() {
    if (state.isFormLocked) return;
    emit(
      state.copyWith(
        clearThumbnail: true,
        status: PublishArticleStatus.initial,
        validationErrors: _withoutErrorsFor({
          PublishArticleField.thumbnailFileName,
          PublishArticleField.thumbnailMimeType,
          PublishArticleField.thumbnailBytes,
        }),
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );
  }

  Future<void> publish() async {
    if (state.isSubmitting) {
      return;
    }

    emit(
      state.copyWith(
        status: PublishArticleStatus.submitting,
        validationErrors: const [],
        clearPublishedArticle: true,
        clearFailureMessage: true,
      ),
    );

    final thumbnail = state.thumbnail ??
        ArticleThumbnail(
          fileName: '',
          mimeType: '',
          bytes: const [],
        );

    final params = PublishArticleParams(
      author: state.author,
      title: state.title,
      description: state.description,
      content: state.content,
      thumbnail: thumbnail,
    );

    try {
      final pendingId = state.pendingArticleId;
      final result = pendingId == null
          ? await _publishArticleUseCase(params: params)
          : await _publishArticleUseCase.confirm(pendingId);

      if (isClosed) {
        return;
      }

      if (result.pendingArticleId != null) {
        emit(state.copyWith(
          status: PublishArticleStatus.confirmationPending,
          pendingArticleId: result.pendingArticleId,
          clearPublishedArticle: true,
          clearFailureMessage: true,
        ));
        return;
      }

      if (result.errors.isNotEmpty) {
        emit(
          state.copyWith(
            status: PublishArticleStatus.validationFailure,
            clearPendingArticle: true,
            validationErrors: result.errors,
            clearPublishedArticle: true,
            clearFailureMessage: true,
          ),
        );
        return;
      }

      final article = result.article;
      if (article == null) {
        throw StateError(
          'PublishArticleResult did not contain an article or errors.',
        );
      }

      emit(
        state.copyWith(
          status: PublishArticleStatus.success,
          clearPendingArticle: true,
          validationErrors: const [],
          publishedArticle: article,
          clearFailureMessage: true,
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: PublishArticleStatus.failure,
          clearPendingArticle: true,
          validationErrors: const [],
          clearPublishedArticle: true,
          failureMessage: 'Unable to publish the article. Please try again.',
        ),
      );
    }
  }

  List<PublishArticleValidationError> _withoutErrorsFor(
    Set<PublishArticleField> fields,
  ) {
    return state.validationErrors
        .where((error) => !fields.contains(error.field))
        .toList(growable: false);
  }
}
