import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/services/analytics_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_draft_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/clear_draft_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/increment_article_views_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/load_draft_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/save_draft_usecase.dart';
import '../../domain/use_cases/upload_article_thumbnail_usecase.dart';
import '../../domain/use_cases/upload_article_usecase.dart';
import 'article_upload_state.dart';

class ArticleUploadCubit extends Cubit<ArticleUploadState> {
  final UploadArticleUseCase _uploadArticleUseCase;
  final UploadArticleThumbnailUseCase _uploadThumbnailUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final LoadDraftUseCase _loadDraftUseCase;
  final ClearDraftUseCase _clearDraftUseCase;
  final IncrementArticleViewsUseCase _incrementViewsUseCase;
  final AnalyticsService _analytics;

  String? _pendingThumbnailUrl;
  Timer? _draftDebounce;
  final Set<String> _viewedArticleIds = {};

  static const _draftDebounceMs = 800;

  ArticleUploadCubit(
    this._uploadArticleUseCase,
    this._uploadThumbnailUseCase,
    this._saveDraftUseCase,
    this._loadDraftUseCase,
    this._clearDraftUseCase,
    this._incrementViewsUseCase,
    this._analytics,
  ) : super(const ArticleUploadInitial());

  @override
  Future<void> close() {
    _draftDebounce?.cancel();
    return super.close();
  }

  void notifyCreationStarted() {
    _analytics.trackEvent(AnalyticsEvent.onStartCreate);
  }

  void notifyDraftRestored() {
    _analytics.trackEvent(AnalyticsEvent.onDraftRestored);
  }

  Future<void> recordArticleView(String articleId) async {
    if (_viewedArticleIds.contains(articleId)) return;
    _viewedArticleIds.add(articleId);
    await _incrementViewsUseCase(articleId);
  }

  Future<ArticleDraftEntity?> loadExistingDraft() async {
    return _loadDraftUseCase();
  }

  void scheduleDraftSave({
    required String title,
    required String content,
    required List<String> tags,
    String? thumbnailLocalPath,
  }) {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(
      const Duration(milliseconds: _draftDebounceMs),
      () => _persistDraft(title, content, tags, thumbnailLocalPath),
    );
  }

  Future<void> discardDraft() async {
    await _clearDraftUseCase();
    _analytics.trackEvent(AnalyticsEvent.onDraftDiscarded);
  }

  Future<void> pickAndUploadThumbnail({
    required String localFilePath,
    required String authorId,
  }) async {
    emit(const ArticleUploadThumbnailLoading());
    try {
      _pendingThumbnailUrl = await _uploadThumbnailUseCase(
        UploadArticleThumbnailParams(
          localFilePath: localFilePath,
          authorId: authorId,
        ),
      );
      emit(ArticleUploadThumbnailReady(_pendingThumbnailUrl!));
    } catch (e) {
      _analytics.trackEvent(
        AnalyticsEvent.onError,
        properties: {'step': 'thumbnail', 'error': '$e'},
      );
      emit(ArticleUploadFailure('Failed to upload image: $e'));
    }
  }

  Future<void> submitArticle({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    required List<String> tags,
  }) async {
    if (_pendingThumbnailUrl == null) {
      emit(const ArticleUploadFailure('Please select a thumbnail first.'));
      return;
    }

    _draftDebounce?.cancel();
    _analytics.trackEvent(AnalyticsEvent.onSubmit, properties: {'title': title});
    emit(const ArticleUploading());

    try {
      final article = await _uploadArticleUseCase(
        UploadArticleParams(
          title: title,
          content: content,
          thumbnailUrl: _pendingThumbnailUrl!,
          authorId: authorId,
          authorName: authorName,
          tags: tags,
        ),
      );
      await _clearDraftUseCase();
      _analytics.trackEvent(AnalyticsEvent.onSuccess, properties: {'articleId': article.id});
      emit(ArticleUploadSuccess(article));
    } catch (e) {
      _analytics.trackEvent(
        AnalyticsEvent.onError,
        properties: {'step': 'submit', 'error': '$e'},
      );
      emit(ArticleUploadFailure('Failed to publish: $e'));
    }
  }

  void reset() {
    _draftDebounce?.cancel();
    _pendingThumbnailUrl = null;
    emit(const ArticleUploadInitial());
  }

  Future<void> _persistDraft(
    String title,
    String content,
    List<String> tags,
    String? thumbnailLocalPath,
  ) async {
    final draft = ArticleDraftEntity(
      title: title,
      content: content,
      tags: tags,
      thumbnailLocalPath: thumbnailLocalPath,
      updatedAt: DateTime.now(),
    );
    if (draft.isEmpty) return;
    await _saveDraftUseCase(draft);
    _analytics.trackEvent(AnalyticsEvent.onDraftSaved);
  }
}
