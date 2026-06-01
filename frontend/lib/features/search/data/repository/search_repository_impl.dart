import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/search/data/data_sources/search_local_data_source.dart';
import 'package:tortutip/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final SearchLocalDataSource _localDataSource;

  SearchRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> searchArticles(String query) async {
    try {
      final models = await _remoteDataSource.searchArticles(query);
      return DataSuccess(models);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<CategoryEntity>>> searchCategories(String query) async {
    try {
      final models = await _remoteDataSource.searchCategories(query);
      return DataSuccess(models);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<UserEntity>>> searchCreators(String query) async {
    try {
      final models = await _remoteDataSource.searchCreators(query);
      return DataSuccess(models);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<String>>> getRecentSearches() async {
    try {
      final results = await _localDataSource.getRecentSearches();
      return DataSuccess(results);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> saveRecentSearch(String query) async {
    try {
      await _localDataSource.saveRecentSearch(query);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> removeRecentSearch(String query) async {
    try {
      await _localDataSource.removeRecentSearch(query);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}
