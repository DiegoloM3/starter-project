import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class RecordFeedSwipeParams extends Equatable {
  final String userId;

  const RecordFeedSwipeParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RecordFeedSwipeUseCase
    implements UseCase<DataState<UserEntity>, RecordFeedSwipeParams> {
  final UserRepository _repository;

  RecordFeedSwipeUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(RecordFeedSwipeParams params) =>
      _repository.recordFeedSwipe(params.userId);
}
