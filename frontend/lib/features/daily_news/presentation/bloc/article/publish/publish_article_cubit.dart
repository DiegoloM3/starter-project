import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_state.dart';

class PublishArticleCubit extends Cubit<PublishArticleState> {
  final PublishArticleUseCase _publishArticleUseCase;
  final PickArticleThumbnailUseCase _pickArticleThumbnailUseCase;

  PublishArticleCubit(this._publishArticleUseCase, this._pickArticleThumbnailUseCase)
      : super(const PublishArticleState());

  void changeTitle(String title) {
    emit(_buildEditingState().copyWith(title: title));
  }

  void changeContent(String content) {
    emit(_buildEditingState().copyWith(content: content));
  }

  Future<void> pickThumbnail() async {
    final pickedThumbnail = await _pickArticleThumbnailUseCase();
    if (pickedThumbnail is DataFailed) {
      emit(state.copyWith(status: PublishArticleStatus.failure));
    } else if (pickedThumbnail.data != null) {
      emit(_buildEditingState().copyWith(thumbnailPath: pickedThumbnail.data));
    }
  }

  Future<void> publish() async {
    if (state.isPublishing) return;
    emit(state.copyWith(status: PublishArticleStatus.publishing, validationErrors: []));
    final publication = await _publishArticleUseCase(params: PublishArticleParams(state.draft));
    if (publication is DataSuccess) {
      emit(state.copyWith(status: PublishArticleStatus.published));
    } else {
      _emitPublicationFailure(publication.error);
    }
  }

  void _emitPublicationFailure(Exception? error) {
    if (error is ArticleDraftValidationException) {
      emit(state.copyWith(status: PublishArticleStatus.invalid, validationErrors: error.errors));
    } else {
      emit(state.copyWith(status: PublishArticleStatus.failure));
    }
  }

  PublishArticleState _buildEditingState() {
    return state.copyWith(status: PublishArticleStatus.editing, validationErrors: []);
  }
}
