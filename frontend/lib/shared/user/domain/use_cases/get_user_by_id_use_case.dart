import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class GetUserByIdParams extends Equatable {
  final String userId;

  const GetUserByIdParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserByIdUseCase implements UseCase<DataState<UserEntity>, GetUserByIdParams> {
  final UserRepository _repository;
  GetUserByIdUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(GetUserByIdParams params) {
    return _repository.getUserById(params.userId);
  }
}
