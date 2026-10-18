import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_content.dart';
import '../../../domain/entities/article_topic.dart';
import '../../../domain/exceptions/article_exceptions.dart';
import '../../../domain/params/article_draft.dart';
import '../../../domain/params/article_image.dart';
import '../../../domain/params/publish_article_params.dart';
import '../../../domain/params/update_article_params.dart';
import '../../../domain/usecases/publish_article.dart';
import '../../../domain/usecases/update_article.dart';
import '../../../domain/usecases/upload_article_image.dart';
import 'article_editor_state.dart';

/// Publishes a new article, or updates an existing one when an article id is given.
class ArticleEditorCubit extends Cubit<ArticleEditorState> {
  final PublishArticleUseCase _publishArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final UploadArticleImageUseCase _uploadArticleImageUseCase;

  ArticleEditorCubit(this._publishArticleUseCase, this._updateArticleUseCase, this._uploadArticleImageUseCase)
    : super(const ArticleEditorState());

  /// A new article without [thumbnail] fails validation; an existing one keeps its current thumbnail.
  Future<void> submit({
    String? articleId,
    required String title,
    required String description,
    required ArticleContent content,
    required Set<ArticleTopic> topics,
    Uint8List? thumbnail,
  }) async {
    emit(const ArticleEditorState(status: ArticleEditorStatus.submitting));
    final draft = ArticleDraft(title: title, description: description, content: content, topics: topics);
    final result = articleId == null ? await _publish(draft, thumbnail) : await _update(articleId, draft, thumbnail);
    emit(_stateFor(result));
  }

  /// Returns the URL to embed in the content, or null when the upload fails.
  /// The validation errors of the last submission stay visible meanwhile.
  Future<String?> uploadContentImage(Uint8List bytes) async {
    final validationErrors = state.validationErrors;
    emit(ArticleEditorState(validationErrors: validationErrors, isUploadingImage: true));
    final result = await _uploadArticleImageUseCase(ArticleImage(bytes));
    final status = result is DataSuccess ? ArticleEditorStatus.editing : ArticleEditorStatus.imageUploadFailure;
    emit(ArticleEditorState(status: status, validationErrors: validationErrors));
    return result.data;
  }

  Future<DataState<ArticleEntity>> _publish(ArticleDraft draft, Uint8List? thumbnail) {
    final thumbnailImage = ArticleImage(thumbnail ?? Uint8List(0));
    return _publishArticleUseCase(PublishArticleParams(draft: draft, thumbnail: thumbnailImage));
  }

  Future<DataState<ArticleEntity>> _update(String articleId, ArticleDraft draft, Uint8List? thumbnail) {
    final newThumbnail = thumbnail == null ? null : ArticleImage(thumbnail);
    return _updateArticleUseCase(UpdateArticleParams(articleId: articleId, draft: draft, newThumbnail: newThumbnail));
  }

  ArticleEditorState _stateFor(DataState<ArticleEntity> result) {
    final error = result.error;
    if (error == null) return ArticleEditorState(status: ArticleEditorStatus.success, savedArticle: result.data);
    final validationErrors = error is ArticleValidationException ? error.errors : <ArticleValidationError>{};
    return ArticleEditorState(status: ArticleEditorStatus.failure, validationErrors: validationErrors);
  }
}
