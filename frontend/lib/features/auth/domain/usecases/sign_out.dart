import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SignOutUseCase implements UseCase<void, void> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<void> call({void params}) {
    return _authRepository.signOut();
  }
}

