import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/auth_failures.dart';
import '../params/request_password_reset_params.dart';
import '../repository/auth_repository.dart';

/// Starts a password reset for an address.
///
/// Reports success even when nobody uses that address, so the app cannot be
/// used to find out who is registered. The only failure it reports on its own
/// is an address that is not shaped like one.
class RequestPasswordResetUseCase
    implements UseCase<DataState<void>, RequestPasswordResetParams> {
  final AuthRepository _authRepository;

  const RequestPasswordResetUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(RequestPasswordResetParams params) async {
    final validationErrors = params.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(CredentialsValidationException(validationErrors));
    }

    return _authRepository.requestPasswordReset(params.email.trim());
  }
}
