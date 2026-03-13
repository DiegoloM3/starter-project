import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Parameters required for signing up.
class SignUpParams {
  final String email;
  final String password;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

/// Use case for creating a new user account.
class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignUpParams? params}) async {
    if (params == null) {
      return DataFailed(Exception('SignUpParams cannot be null'));
    }
    return await _authRepository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
