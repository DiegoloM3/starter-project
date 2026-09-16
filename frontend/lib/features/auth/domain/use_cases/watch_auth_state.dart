import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Emits the signed-in user, or `null`, whenever the session changes.
class WatchAuthStateUseCase implements StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository _authRepository;

  const WatchAuthStateUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return _authRepository.watchAuthState();
  }
}
