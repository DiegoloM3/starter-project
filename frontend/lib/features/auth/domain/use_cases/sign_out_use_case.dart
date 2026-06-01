import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<DataState<bool>, NoParams> {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  @override
  Future<DataState<bool>> call(NoParams params) {
    return _repository.signOut();
  }
}
