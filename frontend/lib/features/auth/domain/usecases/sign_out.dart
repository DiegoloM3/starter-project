import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Use case for signing out the current user.
class SignOutUseCase implements UseCaseNoParams<void> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<void> call() async {
    return await _authRepository.signOut();
  }
}
