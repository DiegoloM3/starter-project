import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Parameters required for changing password.
class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

/// Use case for changing the user's password.
class ChangePasswordUseCase
    implements UseCase<DataState<void>, ChangePasswordParams> {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({ChangePasswordParams? params}) async {
    if (params == null) {
      return DataFailed(Exception('ChangePasswordParams cannot be null'));
    }
    return await _authRepository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
