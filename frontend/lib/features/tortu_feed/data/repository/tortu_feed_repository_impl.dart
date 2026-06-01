import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/tortu_feed/data/data_sources/tortu_feed_remote_data_source.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class TortuFeedRepositoryImpl implements TortuFeedRepository {
  final TortuFeedRemoteDataSource _dataSource;

  TortuFeedRepositoryImpl(this._dataSource);

  @override
  Future<DataState<bool>> feedTortu(FeedTortuParams params) async {
    try {
      await _dataSource.feedTortu(
        userId: params.userId,
        articleId: params.articleId,
        categoryId: params.categoryId,
        date: params.date,
      );
      return const DataSuccess(false);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<bool>> checkTodayTip(CheckTodayTipParams params) async {
    try {
      final result = await _dataSource.checkTodayTip(
        userId: params.userId,
        date: params.date,
      );
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<double>> updateCategoryProgress(
      UpdateCategoryProgressParams params) async {
    try {
      final newProgress = await _dataSource.updateCategoryProgress(
        userId: params.userId,
        categoryId: params.categoryId,
      );
      return DataSuccess(newProgress);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<double>> getCategoryProgress(
      GetCategoryProgressParams params) async {
    try {
      final progress = await _dataSource.getCategoryProgress(
        userId: params.userId,
        categoryId: params.categoryId,
      );
      return DataSuccess(progress);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<int>> getStreakDays(String userId) async {
    try {
      final days = await _dataSource.getStreakDays(userId: userId);
      return DataSuccess(days);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<double>> getOverallProgress(String userId) async {
    try {
      final progress = await _dataSource.getOverallProgress(userId: userId);
      return DataSuccess(progress);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }
}
