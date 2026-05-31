import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/create_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_cover_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/update_community_article.dart';

import 'community_article_editor_event.dart';
import 'community_article_editor_state.dart';

class CommunityArticleEditorBloc
    extends Bloc<CommunityArticleEditorEvent, CommunityArticleEditorState> {
  CommunityArticleEditorBloc(
    this._createCommunityArticle,
    this._updateCommunityArticle,
    this._pickCoverImage,
  ) : super(const CommunityArticleEditorState()) {
    on<CommunityArticleEditorLoaded>(_onLoaded);
    on<CommunityArticleCoverImagePickRequested>(_onCoverImagePickRequested);
    on<CommunityArticleCoverImageRemoveRequested>(_onCoverImageRemoveRequested);
    on<CommunityArticlePublishRequested>(_onPublishRequested);
    on<CommunityArticleUpdateRequested>(_onUpdateRequested);
    on<CommunityArticleEditorResetRequested>(_onResetRequested);
  }

  final CreateCommunityArticleUseCase _createCommunityArticle;
  final UpdateCommunityArticleUseCase _updateCommunityArticle;
  final PickCoverImageUseCase _pickCoverImage;

  void _onLoaded(
    CommunityArticleEditorLoaded event,
    Emitter<CommunityArticleEditorState> emit,
  ) {
    emit(
      state.copyWith(
        article: event.article,
        removeImage: false,
        clearSelectedImage: true,
        clearFailure: true,
      ),
    );
  }

  Future<void> _onCoverImagePickRequested(
    CommunityArticleCoverImagePickRequested event,
    Emitter<CommunityArticleEditorState> emit,
  ) async {
    final result = await _pickCoverImage();

    switch (result) {
      case DataSuccess<dynamic>(:final data):
        if (data == null) {
          return;
        }
        emit(
          state.copyWith(
            selectedImageFile: data,
            removeImage: false,
            clearFailure: true,
          ),
        );
      case DataFailed<dynamic>(:final failure):
        emit(
          state.copyWith(
            status: CommunityArticleEditorStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  void _onCoverImageRemoveRequested(
    CommunityArticleCoverImageRemoveRequested event,
    Emitter<CommunityArticleEditorState> emit,
  ) {
    emit(
      state.copyWith(
        clearSelectedImage: true,
        removeImage: event.hadExistingImage,
        clearFailure: true,
      ),
    );
  }

  Future<void> _onPublishRequested(
    CommunityArticlePublishRequested event,
    Emitter<CommunityArticleEditorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CommunityArticleEditorStatus.submitting,
        clearFailure: true,
      ),
    );

    final result = await _createCommunityArticle(params: event.params);
    _emitResult(result, emit);
  }

  Future<void> _onUpdateRequested(
    CommunityArticleUpdateRequested event,
    Emitter<CommunityArticleEditorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CommunityArticleEditorStatus.submitting,
        clearFailure: true,
      ),
    );

    final result = await _updateCommunityArticle(params: event.params);
    _emitResult(result, emit);
  }

  void _onResetRequested(
    CommunityArticleEditorResetRequested event,
    Emitter<CommunityArticleEditorState> emit,
  ) {
    emit(const CommunityArticleEditorState());
  }

  void _emitResult(
    DataState<dynamic> result,
    Emitter<CommunityArticleEditorState> emit,
  ) {
    switch (result) {
      case DataSuccess<dynamic>(:final data):
        emit(
          state.copyWith(
            status: CommunityArticleEditorStatus.success,
            article: data,
            clearFailure: true,
          ),
        );
      case DataFailed<dynamic>(:final failure):
        emit(
          state.copyWith(
            status: CommunityArticleEditorStatus.failure,
            failure: failure,
          ),
        );
    }
  }
}
