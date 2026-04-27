import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}

class ForgotPasswordUseCase
    implements UseCase<DataState<void>, ForgotPasswordParams> {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({ForgotPasswordParams? params}) {
    return _authRepository.forgotPassword(email: params!.email);
  }
}
