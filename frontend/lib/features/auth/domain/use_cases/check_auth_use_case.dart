import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class CheckAuthUseCase implements UseCase<DataState<UserEntity>, NoParams> {
  final AuthRepository _repository;
  CheckAuthUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(NoParams params) {
    return _repository.checkCurrentAuth();
  }
}
