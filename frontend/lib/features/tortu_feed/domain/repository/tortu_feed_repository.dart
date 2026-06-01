import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';

abstract class TortuFeedRepository {
  Future<DataState<bool>> feedTortu(FeedTortuParams params);
  Future<DataState<bool>> checkTodayTip(CheckTodayTipParams params);
  Future<DataState<double>> updateCategoryProgress(UpdateCategoryProgressParams params);
  Future<DataState<double>> getCategoryProgress(GetCategoryProgressParams params);
  Future<DataState<int>> getStreakDays(String userId);
  Future<DataState<double>> getOverallProgress(String userId);
}

class FeedTortuParams extends Equatable {
  final String userId;
  final String articleId;
  final String categoryId;
  final String date;

  const FeedTortuParams({
    required this.userId,
    required this.articleId,
    required this.categoryId,
    required this.date,
  });

  @override
  List<Object?> get props => [userId, articleId, categoryId, date];
}

class CheckTodayTipParams extends Equatable {
  final String userId;
  final String date;

  const CheckTodayTipParams({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

class UpdateCategoryProgressParams extends Equatable {
  final String userId;
  final String categoryId;

  const UpdateCategoryProgressParams({required this.userId, required this.categoryId});

  @override
  List<Object?> get props => [userId, categoryId];
}

class GetCategoryProgressParams extends Equatable {
  final String userId;
  final String categoryId;

  const GetCategoryProgressParams({required this.userId, required this.categoryId});

  @override
  List<Object?> get props => [userId, categoryId];
}
