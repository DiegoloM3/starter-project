import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';

import '../../domain/entities/community_article_entity.dart';
import '../../domain/params/community_article_params.dart';
import '../../domain/repository/community_article_repository.dart';
import '../datasources/remote/firebase_storage_datasource.dart';
import '../datasources/remote/firestore_articles_datasource.dart';

@LazySingleton(as: CommunityArticleRepository)
class CommunityArticleRepositoryImpl implements CommunityArticleRepository {
  final FirestoreArticlesDataSource _firestoreDataSource;
  final FirebaseStorageDataSource _storageDataSource;

  CommunityArticleRepositoryImpl(
    this._firestoreDataSource,
    this._storageDataSource,
  );

  @override
  Future<DataState<PaginatedResult<CommunityArticleEntity>>>
  getCommunityArticles({required CommunityArticleParams params}) async {
    try {
      final models = await _firestoreDataSource.getArticles(
        params.pageSize,
        params.lastDocumentId,
      );

      // Firestore doesn't expose total count efficiently.
      // Heuristic: if we got a full page, assume there are more.
      final totalResults = models.length < params.pageSize
          ? models.length
          : models.length + 1;

      return DataSuccess(
        PaginatedResult(
          page: 1,
          pageSize: params.pageSize,
          totalResults: totalResults,
          articles: models.map((m) => m.toEntity()).toList(),
        ),
      );
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Stream<DataState<List<CommunityArticleEntity>>> watchCommunityArticles({
    required CommunityArticleParams params,
  }) async* {
    try {
      await for (final models in _firestoreDataSource.watchArticles(
        params.pageSize,
      )) {
        yield DataSuccess(models.map((m) => m.toEntity()).toList());
      }
    } on ServerException catch (e) {
      yield DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<CommunityArticleEntity>> getCommunityArticleById({
    required String id,
  }) async {
    try {
      final model = await _firestoreDataSource.getArticleById(id);
      return DataSuccess(model.toEntity());
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<List<CommunityArticleEntity>>> getUserArticles({
    required String userId,
  }) async {
    try {
      final models = await _firestoreDataSource.getUserArticles(userId);
      return DataSuccess(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<CommunityArticleEntity>> createCommunityArticle({
    required CreateArticleParams params,
  }) async {
    try {
      String? imageUrl;
      if (params.imageFile != null) {
        imageUrl = await _storageDataSource.uploadArticleImage(
          params.authorId,
          params.imageFile!,
        );
      }

      final model = await _firestoreDataSource.createArticle(
        authorId: params.authorId,
        authorName: params.authorName,
        title: params.title,
        content: params.content,
        description: params.description,
        imageUrl: imageUrl,
        category: params.category,
      );

      return DataSuccess(model.toEntity());
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<CommunityArticleEntity>> updateCommunityArticle({
    required UpdateArticleParams params,
  }) async {
    try {
      String? newImageUrl;
      String? oldImageUrl;

      // Fetch current image URL only when we need to clean up storage.
      if (params.imageFile != null || params.removeImage) {
        final existing = await _firestoreDataSource.getArticleById(params.id);
        oldImageUrl = existing.imageUrl;
      }

      if (params.imageFile != null) {
        newImageUrl = await _storageDataSource.uploadArticleImage(
          params.authorId,
          params.imageFile!,
        );
        if (oldImageUrl != null) {
          await _storageDataSource.deleteImageByUrl(oldImageUrl);
        }
      } else if (params.removeImage && oldImageUrl != null) {
        await _storageDataSource.deleteImageByUrl(oldImageUrl);
      }

      final model = await _firestoreDataSource.updateArticle(
        id: params.id,
        title: params.title,
        content: params.content,
        description: params.description,
        imageUrl: newImageUrl,
        removeImageUrl: params.removeImage && params.imageFile == null,
        category: params.category,
      );

      return DataSuccess(model.toEntity());
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<void>> deleteCommunityArticle({required String id}) async {
    try {
      // Fetch imageUrl before deletion so we can clean up Storage.
      final article = await _firestoreDataSource.getArticleById(id);
      await _firestoreDataSource.deleteArticle(id);

      if (article.imageUrl != null) {
        await _storageDataSource.deleteImageByUrl(article.imageUrl!);
      }

      return const DataSuccess(null);
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
