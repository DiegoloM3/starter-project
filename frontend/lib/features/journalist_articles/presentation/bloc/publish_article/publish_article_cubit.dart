import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';

import 'publish_article_state.dart';

class PublishArticleCubit extends Cubit<PublishArticleState> {
  final PublishArticleUseCase _publishArticleUseCase;
  final PickArticleThumbnailUseCase _pickArticleThumbnailUseCase;

  PublishArticleCubit(this._publishArticleUseCase, this._pickArticleThumbnailUseCase)
      : super(const PublishArticleEditing(ArticleDraftEntity()));

  void updateTitle(String title) => _updateDraft(state.draft.copyWith(title: title));

  void updateDescription(String description) =>
      _updateDraft(state.draft.copyWith(description: description));

  void updateContent(String content) => _updateDraft(state.draft.copyWith(content: content));

  Future<void> pickThumbnail() async {
    final dataState = await _pickArticleThumbnailUseCase();
    if (dataState is DataFailed) {
      emit(PublishArticleFailure(state.draft, dataState.error!));
      return;
    }
    final thumbnail = dataState.data;
    if (thumbnail != null) _updateDraft(state.draft.copyWith(thumbnail: thumbnail));
  }

  Future<void> publish() async {
    emit(PublishArticleInProgress(state.draft));
    final dataState = await _publishArticleUseCase(params: state.draft);
    if (dataState is DataSuccess) {
      emit(PublishArticleSuccess(state.draft, dataState.data!));
      return;
    }
    _emitPublishFailure(dataState.error!);
  }

  void _emitPublishFailure(Exception error) {
    if (error is InvalidArticleDraftException) {
      emit(PublishArticleEditing(state.draft, showsValidationErrors: true));
      return;
    }
    emit(PublishArticleFailure(state.draft, error));
  }

  void _updateDraft(ArticleDraftEntity draft) {
    emit(PublishArticleEditing(draft, showsValidationErrors: _showsValidationErrors));
  }

  bool get _showsValidationErrors {
    final state = this.state;
    return state is PublishArticleEditing && state.showsValidationErrors;
  }
}
