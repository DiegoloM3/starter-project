import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignInAnonymousUseCase implements UseCase<UserEntity, void> {
  final AuthRepository _authRepository;

  SignInAnonymousUseCase(this._authRepository);

  @override
  Future<UserEntity> call({void params}) {
    return _authRepository.signInAnonymous();
  }
}
