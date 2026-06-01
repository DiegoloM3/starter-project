import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class UpdateUserProfileParams extends Equatable {
  final UserEntity user;

  const UpdateUserProfileParams({required this.user});

  @override
  List<Object?> get props => [user];
}

class UpdateUserProfileUseCase
    implements UseCase<DataState<UserEntity>, UpdateUserProfileParams> {
  final UserRepository _repository;
  UpdateUserProfileUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(UpdateUserProfileParams params) {
    return _repository.updateUserProfile(params.user);
  }
}
