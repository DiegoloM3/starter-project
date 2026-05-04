import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/draft_dao.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/article_storage_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class ArticleUploadRepositoryImpl implements ArticleUploadRepository {
  final ArticlesFirestoreService _firestoreService;
  final ArticleStorageService _storageService;
  final DraftDao _draftDao;
  final FirebaseAuth _firebaseAuth;

  ArticleUploadRepositoryImpl(
    this._firestoreService,
    this._storageService,
    this._draftDao,
    this._firebaseAuth,
  );

  @override
  Future<DataState<JournalistArticleEntity>> publish(
      PublishArticleParams params) async {
    try {
      if (params.imageBytes.isEmpty) {
        return DataFailed(const ValidationException(
            message: 'A thumbnail image is required to publish.'));
      }

      final user = _firebaseAuth.currentUser;
      if (user == null || user.isAnonymous) {
        return const DataFailed(AuthException(
          message: 'must be authenticated to publish',
          code: 'unauthenticated',
        ));
      }

      final articleId = _firestoreService.allocateArticleId();
      final now = DateTime.now();

      final publishingModel = JournalistArticleModel(
        id: articleId,
        title: params.title,
        description: params.description,
        content: params.content,
        urlToImage: 'pending://thumbnail',
        publishedAt: now,
        userId: params.userId,
        userDisplayName: params.userDisplayName,
        userPhotoUrl: params.userPhotoUrl,
        source: 'journalist',
        category: params.category,
        tags: params.tags,
        language: params.language,
        readingTimeMinutes:
            JournalistArticleEntity.estimateReadingTime(params.content),
        location: params.location,
        status: ArticleStatus.publishing,
        createdAt: now,
        updatedAt: now,
        viewCount: 0,
        favoriteCount: 0,
      );

      await _firestoreService.createArticle(publishingModel);

      String downloadUrl;
      try {
        downloadUrl = await _storageService.uploadThumbnail(
          articleId: articleId,
          bytes: params.imageBytes,
          contentType: 'image/jpeg',
        );
      } on StorageException catch (e) {
        // Leave the doc for potential retry; mark it upload_failed so rules
        // prevent it from appearing in feeds until repaired.
        await _firestoreService
            .updateArticle(articleId, {'status': 'upload_failed'})
            .catchError((_) {});
        return DataFailed(e);
      }

      await _firestoreService.updateArticle(articleId, {
        'urlToImage': downloadUrl,
        'status': ArticleStatus.published.toApiValue(),
      });

      if (params.draftId != null) {
        await _draftDao.deleteDraft(params.draftId!);
      }

      final entity = publishingModel.copyWith(
        urlToImage: downloadUrl,
        status: ArticleStatus.published,
      );

      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Future<DataState<JournalistArticleEntity>> update(
      UpdateArticleParams params) async {
    try {
      if (params.newImageBytes != null &&
          params.newImageBytes!.isNotEmpty) {
        final url = await _storageService.uploadThumbnail(
          articleId: params.articleId,
          bytes: params.newImageBytes!,
          contentType: 'image/jpeg',
        );
        await _firestoreService.updateArticle(params.articleId, {
          ..._updatePartial(params),
          'urlToImage': url,
        });
      } else {
        await _firestoreService
            .updateArticle(params.articleId, _updatePartial(params));
      }

      final now = DateTime.now();
      final entity = JournalistArticleModel(
        id: params.articleId,
        title: params.title,
        description: params.description,
        content: params.content,
        urlToImage: '',
        publishedAt: now,
        userId: '',
        userDisplayName: '',
        source: 'journalist',
        category: params.category,
        tags: params.tags,
        language: params.language,
        readingTimeMinutes:
            JournalistArticleEntity.estimateReadingTime(params.content),
        location: params.location,
        status: ArticleStatus.published,
        createdAt: now,
        updatedAt: now,
        viewCount: 0,
        favoriteCount: 0,
      );

      return DataSuccess(entity);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  Map<String, dynamic> _updatePartial(UpdateArticleParams params) => {
        'title': params.title,
        'description': params.description,
        'content': params.content,
        'category': params.category.toApiValue(),
        'tags': params.tags,
        'language': params.language,
        if (params.location != null)
          'location': {
            'latitude': params.location!.latitude,
            'longitude': params.location!.longitude,
            'placeName': params.location!.placeName,
          },
      };

  @override
  Future<DataState<void>> delete(DeleteArticleParams params) async {
    try {
      await _firestoreService.deleteArticle(params.articleId);
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Stream<List<JournalistArticleEntity>> watchByAuthor(String userId) {
    return _firestoreService
        .watchByAuthor(userId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<JournalistArticleEntity>> watchCommunityFeed({int limit = 20}) {
    return _firestoreService
        .watchCommunityFeed(limit: limit)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<JournalistArticleEntity?> watchById(String articleId) {
    return _firestoreService
        .watchArticleById(articleId)
        .map((m) => m?.toEntity());
  }

  @override
  Future<DataState<void>> toggleFavorite(ToggleFavoriteParams params) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.isAnonymous) {
        return const DataFailed(AuthException(
          message: 'must be authenticated to favorite',
          code: 'unauthenticated',
        ));
      }
      await _firestoreService.toggleFavorite(
        articleId: params.articleId,
        userId: user.uid,
        currentlyFavorited: params.currentlyFavorited,
      );
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Stream<List<String>> watchFavoriteArticleIds(String userId) {
    return _firestoreService.watchFavoriteArticleIds(userId);
  }

  @override
  Future<DataState<int>> saveDraft(SaveDraftParams params) async {
    try {
      final model = DraftArticleModel(
        draftId: params.id == 0 ? null : params.id,
        title: params.title,
        description: params.description,
        content: params.content,
        localImagePath: params.localImagePath,
        categoryRaw: params.category?.toApiValue(),
        tagsRaw: params.tags.join(','),
        language: params.language,
        locationLat: params.location?.latitude,
        locationLng: params.location?.longitude,
        locationPlaceName: params.location?.placeName,
        lastSavedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      final id = await _draftDao.upsertDraft(model);
      return DataSuccess(id);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Stream<List<DraftArticleEntity>> watchDrafts() {
    return _draftDao
        .watchDrafts()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<DataState<DraftArticleEntity?>> getDraftById(int draftId) async {
    try {
      final model = await _draftDao.getDraft(draftId);
      return DataSuccess(model?.toEntity());
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Future<DataState<void>> deleteDraft(DraftIdParams params) async {
    try {
      await _draftDao.deleteDraft(params.draftId);
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
          UnknownException(message: e.toString(), cause: e, stackTrace: st));
    }
  }
}
