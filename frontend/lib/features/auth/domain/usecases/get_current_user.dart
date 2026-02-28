import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repository/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<AuthUser?, void> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<AuthUser?> call({void params}) {
    return _authRepository.getCurrentUser();
  }
}

