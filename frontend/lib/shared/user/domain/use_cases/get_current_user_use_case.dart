import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class GetCurrentUserUseCase implements UseCase<DataState<UserEntity>, NoParams> {
  final UserRepository _repository;
  GetCurrentUserUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
