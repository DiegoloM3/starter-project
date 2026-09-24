import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/app_user.dart';
import '../entities/auth_failures.dart';
import '../params/sign_up_params.dart';
import '../repository/auth_repository.dart';

/// Registers a new journalist and leaves them signed in.
class SignUpUseCase implements UseCase<DataState<AppUserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  const SignUpUseCase(this._authRepository);

  @override
  Future<DataState<AppUserEntity>> call(SignUpParams params) async {
    final validationErrors = params.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(CredentialsValidationException(validationErrors));
    }

    return _authRepository.signUp(
      email: params.email.trim(),
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }
}
