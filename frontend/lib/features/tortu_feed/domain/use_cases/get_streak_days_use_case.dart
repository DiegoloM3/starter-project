import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class GetStreakDaysParams extends Equatable {
  final String userId;
  const GetStreakDaysParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class GetStreakDaysUseCase
    implements UseCase<DataState<int>, GetStreakDaysParams> {
  final TortuFeedRepository _repository;
  GetStreakDaysUseCase(this._repository);

  @override
  Future<DataState<int>> call(GetStreakDaysParams params) =>
      _repository.getStreakDays(params.userId);
}
