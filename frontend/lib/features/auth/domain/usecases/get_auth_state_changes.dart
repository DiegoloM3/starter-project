import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Use case for listening to authentication state changes.
class GetAuthStateChangesUseCase implements StreamUseCaseNoParams<UserEntity?> {
  final AuthRepository _authRepository;

  GetAuthStateChangesUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call() {
    return _authRepository.authStateChanges;
  }
}
