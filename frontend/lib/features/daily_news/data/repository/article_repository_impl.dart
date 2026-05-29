import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/shared/data/errors/exception_mapper.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirestoreArticleDataSource _firestoreDataSource;
  final FirebaseStorageDataSource _storageDataSource;
  final AuthRepository _authRepository;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._appDatabase,
    this._firestoreDataSource,
    this._storageDataSource,
    this._authRepository,
  );

  // --- News API ---

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final entities = httpResponse.data.articles
            .map((model) => model.toEntity())
            .toList();
        return DataSuccess(entities);
      } else {
        return DataFailed(
          AppException(
            message: httpResponse.response.statusMessage ?? 'Unknown error',
            code: '${httpResponse.response.statusCode}',
          ),
        );
      }
    } on DioError catch (e) {
      return DataFailed(ExceptionMapper.fromDioError(e));
    }
  }

  // --- Local database ---

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() async {
    try {
      final models = await _appDatabase.articleDAO.getArticles();
      final entities = models.map((model) => model.toEntity()).toList();
      return DataSuccess(entities);
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  @override
  Future<DataState<void>> removeArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .deleteArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .insertArticle(ArticleModel.fromEntity(article));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  // --- Firestore CRUD ---

  @override
  Future<DataState<ArticleEntity>> createArticle(
      ArticleEntity article) async {
    try {
      final model = ArticleModel.fromEntity(article);
      final created = await _firestoreDataSource.createArticle(model);
      return DataSuccess(created.toEntity());
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(
      ArticleEntity article) async {
    try {
      final model = ArticleModel.fromEntity(article);
      final updated = await _firestoreDataSource.updateArticle(model);
      return DataSuccess(updated.toEntity());
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    try {
      await _firestoreDataSource.deleteArticle(articleId);
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  // --- Merged feed (News API + Firestore) ---

  @override
  Stream<DataState<List<ArticleEntity>>> getFeedArticles() async* {
    final apiArticles = await _fetchApiArticlesSafely();
    yield* _firestoreDataSource.getPublishedArticles().transform(
          StreamTransformer<List<ArticleModel>,
              DataState<List<ArticleEntity>>>.fromHandlers(
            handleData: (models, sink) {
              final firestoreEntities =
                  models.map((m) => m.toEntity()).toList();
              sink.add(
                DataSuccess(_mergeSorted(apiArticles, firestoreEntities)),
              );
            },
            handleError: (error, stackTrace, sink) {
              if (apiArticles.isNotEmpty) {
                sink.add(DataSuccess(apiArticles));
                return;
              }
              sink.add(
                DataFailed(ExceptionMapper.fromException(error)),
              );
            },
          ),
        );
  }

  Future<List<ArticleEntity>> _fetchApiArticlesSafely() async {
    try {
      final result =
          await getNewsArticles().timeout(const Duration(seconds: 10));
      if (result is DataSuccess && result.data != null) {
        return result.data!;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  List<ArticleEntity> _mergeSorted(
    List<ArticleEntity> apiArticles,
    List<ArticleEntity> firestoreArticles,
  ) {
    final combined = [...firestoreArticles, ...apiArticles];
    combined.sort((a, b) {
      final aDate = DateTime.tryParse(a.publishedAt ?? '');
      final bDate = DateTime.tryParse(b.publishedAt ?? '');
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return combined;
  }

  // --- Firestore real-time streams ---

  @override
  Stream<DataState<List<ArticleEntity>>> getPublishedArticles() {
    return _wrapArticleStream(
        _firestoreDataSource.getPublishedArticles());
  }

  @override
  Stream<DataState<List<ArticleEntity>>> getUserArticles(String userId) {
    return _wrapArticleStream(
        _firestoreDataSource.getUserArticles(userId));
  }

  @override
  Stream<DataState<List<ArticleEntity>>> getDraftArticles(String userId) {
    return _wrapArticleStream(
        _firestoreDataSource.getDraftArticles(userId));
  }

  Stream<DataState<List<ArticleEntity>>> _wrapArticleStream(
    Stream<List<ArticleModel>> source,
  ) {
    return source.transform(
      StreamTransformer<List<ArticleModel>,
          DataState<List<ArticleEntity>>>.fromHandlers(
        handleData: (models, sink) {
          sink.add(
            DataSuccess(models.map((m) => m.toEntity()).toList()),
          );
        },
        handleError: (error, stackTrace, sink) {
          sink.add(DataFailed(ExceptionMapper.fromException(error)));
        },
      ),
    );
  }

  // --- Storage ---

  @override
  Future<DataState<String>> uploadThumbnail({
    required String articleId,
    required String filePath,
  }) async {
    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) {
        return const DataFailed(
          AuthException(
            message: 'User not authenticated',
            code: 'unauthenticated',
          ),
        );
      }
      final downloadUrl = await _storageDataSource.uploadThumbnail(
        uid: uid,
        articleId: articleId,
        filePath: filePath,
      );
      return DataSuccess(downloadUrl);
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }
}
