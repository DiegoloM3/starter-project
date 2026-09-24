import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/app_user.dart';
import '../entities/auth_failures.dart';
import '../params/sign_in_params.dart';
import '../repository/auth_repository.dart';

/// Signs an existing journalist in.
class SignInUseCase implements UseCase<DataState<AppUserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  const SignInUseCase(this._authRepository);

  @override
  Future<DataState<AppUserEntity>> call(SignInParams params) async {
    final validationErrors = params.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(CredentialsValidationException(validationErrors));
    }

    return _authRepository.signIn(
      email: params.email.trim(),
      password: params.password,
    );
  }
}
