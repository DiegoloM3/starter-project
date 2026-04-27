import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

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

class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignUpParams? params}) {
    return _authRepository.signUp(
      email: params!.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
