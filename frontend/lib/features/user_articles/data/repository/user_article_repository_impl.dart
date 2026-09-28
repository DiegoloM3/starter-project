import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/services/connectivity_service.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/user_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_user_article_params.dart';

import '../../domain/params/upload_user_article_params.dart';
import '../../domain/repository/user_article_repository.dart';

class UserArticleRepositoryImpl implements UserArticleRepository {
  final UserArticleFirestoreDataSource _dataSource;
  final ConnectivityService _connectivityService;

  UserArticleRepositoryImpl({
    required UserArticleFirestoreDataSource dataSource,
    required ConnectivityService connectivityService,
  })  : _dataSource = dataSource,
        _connectivityService = connectivityService;

  static const _noConnectionMessage = 'Sin conexión a internet. Intenta más tarde.';

  Future<DataState<T>?> _requireConnection<T>() async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return DataFailed<T>(Exception(_noConnectionMessage));
    }
    return null;
  }

  @override
  Future<DataState<void>> uploadArticle(UploadUserArticleParams params) async {
    final noConnection = await _requireConnection<void>();
    if (noConnection != null) return noConnection;
    try {
      final thumbnailUrl = await _dataSource.uploadThumbnail(params.image);
      final model = UserArticleModel(
        title: params.title,
        content: params.content,
        thumbnailUrl: thumbnailUrl,
        publishedAt: DateTime.now(),
      );
      await _dataSource.saveArticle(model.toJson());
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e as Exception);
    }
  }

  @override
  Future<DataState<List<UserArticleEntity>>> getMyArticles() async {
    final noConnection = await _requireConnection<List<UserArticleEntity>>();
    if (noConnection != null) return noConnection;
    try {
      final rawList = await _dataSource.getArticles();
      final entities = rawList.map((raw) => UserArticleModel.fromRawData(raw).toEntity()).toList();
      return DataSuccess(entities);
    } catch (e) {
      return DataFailed(e as Exception);
    }
  }

  @override
  Future<DataState<void>> deleteArticle(DeleteUserArticleParams params) async {
    final noConnection = await _requireConnection<void>();
    if (noConnection != null) return noConnection;
    try {
      await _dataSource.deleteArticle(params.id, params.thumbnailUrl);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e as Exception);
    }
  }
}