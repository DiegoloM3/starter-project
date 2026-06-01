import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';

class GetOverallProgressParams extends Equatable {
  final String userId;
  const GetOverallProgressParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class GetOverallProgressUseCase
    implements UseCase<DataState<double>, GetOverallProgressParams> {
  final TortuFeedRepository _repository;
  GetOverallProgressUseCase(this._repository);

  @override
  Future<DataState<double>> call(GetOverallProgressParams params) =>
      _repository.getOverallProgress(params.userId);
}
