import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Parameters required for forgot password.
class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}

/// Use case for sending a password reset email.
class ForgotPasswordUseCase
    implements UseCase<DataState<void>, ForgotPasswordParams> {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({ForgotPasswordParams? params}) async {
    if (params == null) {
      return DataFailed(Exception('ForgotPasswordParams cannot be null'));
    }
    return await _authRepository.forgotPassword(email: params.email);
  }
}
