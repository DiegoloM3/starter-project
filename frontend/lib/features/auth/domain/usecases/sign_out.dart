import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(NoParams params) => _authRepository.signOut();
}
