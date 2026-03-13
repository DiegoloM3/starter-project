import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Parameters required for signing in.
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}

/// Use case for signing in a user.
class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignInParams? params}) async {
    if (params == null) {
      return DataFailed(Exception('SignInParams cannot be null'));
    }
    return await _authRepository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
