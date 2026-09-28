import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Credentials required by [LoginUseCase].
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// Single operation: signs in with email and password.
class LoginUseCase implements UseCase<DataState<UserEntity>, LoginParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({LoginParams? params}) async {
    if (params == null) {
      return const DataGenericFailed('Missing login parameters');
    }
    return await _authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}
