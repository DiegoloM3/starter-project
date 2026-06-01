import 'dart:io';

import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles(
    String userId,
    int limit,
  ) async {
    try {
      final rawMaps = await _dataSource.getSavedArticles(userId, limit);
      final models = rawMaps.map((m) => ArticleModel.fromRawData(m)).toList();
      return DataSuccess(List<ArticleEntity>.from(models));
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getPublishedArticles(
    String authorId,
    int limit,
  ) async {
    try {
      final rawMaps = await _dataSource.getPublishedArticles(authorId, limit);
      final models = rawMaps.map((m) => ArticleModel.fromRawData(m)).toList();
      return DataSuccess(List<ArticleEntity>.from(models));
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<bool>> deleteArticle(
    String articleId,
    String userId,
  ) async {
    try {
      await _dataSource.deleteArticle(articleId, userId);
      return const DataSuccess(true);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<String>> uploadAvatar(File imageFile, String userId) async {
    try {
      final url = await _dataSource.uploadAvatar(imageFile, userId);
      return DataSuccess(url);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }
}
