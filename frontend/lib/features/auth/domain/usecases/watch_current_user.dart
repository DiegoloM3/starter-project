import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Emits the signed in user, or null when nobody is signed in.
class WatchCurrentUserUseCase implements StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository _authRepository;

  WatchCurrentUserUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call(NoParams params) => _authRepository.watchCurrentUser();
}
