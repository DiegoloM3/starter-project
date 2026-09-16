import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<DataState<UserEntity>, NoParams> {
  final AuthRepository _authRepository;

  const SignInWithGoogleUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call(NoParams params) {
    return _authRepository.signInWithGoogle();
  }
}
