import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/article_upload_dao.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/article_upload_floor_entity.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/articles_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/auth_session.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/models/article_upload_model.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class ArticlesUploadRepositoryImpl implements ArticlesUploadRepository {
  final ArticlesFirestoreDataSource _firestoreSource;
  final ArticlesStorageDataSource _storageSource;
  final AuthSession _authSession;
  final ArticleUploadDao _localDao;

  ArticlesUploadRepositoryImpl(
    this._firestoreSource,
    this._storageSource,
    this._authSession,
    this._localDao,
  );

  @override
  int get pageSize => ArticlesFirestoreDataSource.pageSize;
  @override
  Future<DataState<List<ArticleUploadEntity>>> getAllArticles() async {
    try {
      final cached = await _localDao.getAllLive();
      if (cached.isNotEmpty) {
        return DataSuccess(cached.map((e) => e.toEntity()).toList());
      }

      return await _fetchAndCache();
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleUploadEntity>>> fetchRemoteAndSync() async {
    return _fetchAndCache();
  }

  Future<DataState<List<ArticleUploadEntity>>> _fetchAndCache() async {
    try {
      final models = await _firestoreSource.fetchAll();

      await _localDao.clearAll();
      if (models.isNotEmpty) {
        await _localDao.upsertAll(
          models.map(ArticleUploadFloorEntity.fromEntity).toList(),
        );
      }

      return DataSuccess(models);
    } on FirebaseException catch (e) {
      final fallback = await _localDao.getAllLive();
      if (fallback.isNotEmpty) {
        return DataSuccess(fallback.map((e) => e.toEntity()).toList());
      }
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleUploadEntity>>> fetchNextPage(
    DateTime lastPublishedAt,
  ) async {
    try {
      final models = await _firestoreSource.fetchNextPage(lastPublishedAt);
      if (models.isNotEmpty) {
        await _localDao.upsertAll(
          models.map(ArticleUploadFloorEntity.fromEntity).toList(),
        );
      }
      return DataSuccess(models);
    } on FirebaseException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ArticleUploadEntity>> getArticleById(String id) async {
    try {
      final model = await _firestoreSource.fetchById(id);
      return DataSuccess(model);
    } on FirebaseException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ArticleUploadEntity>> createArticle(
    CreateArticleParams params,
  ) async {
    try {
      final authorUid = await _authSession.ensureSignedIn();
      final thumbnailURL =
          await _storageSource.uploadThumbnail(params.thumbnailFile);
      final now = DateTime.now();
      final model = ArticleUploadModel(
        title: params.title,
        description: params.description,
        content: params.content,
        author: params.author,
        authorUid: authorUid,
        thumbnailURL: thumbnailURL,
        sourceName: params.sourceName,
        publishedAt: params.publishedAt,
        createdAt: now,
        updatedAt: now,
      );
      final saved = await _firestoreSource.create(model);

      await _localDao.upsertArticle(ArticleUploadFloorEntity.fromEntity(saved));

      return DataSuccess(saved);
    } on FirebaseException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ArticleUploadEntity>> updateArticle(
    UpdateArticleParams params,
  ) async {
    try {
      await _authSession.ensureSignedIn();

      String? newThumbnailURL;
      if (params.newThumbnailFile != null) {
        newThumbnailURL =
            await _storageSource.uploadThumbnail(params.newThumbnailFile!);
      }

      final existing = await _firestoreSource.fetchById(params.id);
      final updated = ArticleUploadModel(
        id: existing.id,
        title: params.title,
        description: params.description,
        content: params.content,
        author: params.author,
        authorUid: existing.authorUid,
        thumbnailURL: newThumbnailURL ?? existing.thumbnailURL,
        sourceName: params.sourceName,
        publishedAt: params.publishedAt,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      final saved =
          await _firestoreSource.update(params.id, updated.toFirestoreUpdate());

      await _localDao.upsertArticle(ArticleUploadFloorEntity.fromEntity(saved));

      return DataSuccess(saved);
    } on FirebaseException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String id) async {
    try {
      await _authSession.ensureSignedIn();
      await _firestoreSource.softDelete(id);

      await _localDao.removeById(id);

      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(e);
    }
  }
}
