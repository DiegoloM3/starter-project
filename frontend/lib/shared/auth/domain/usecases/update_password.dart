import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/password_change.dart';

class UpdatePasswordUseCase implements UseCase<void, PasswordChange> {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  @override
  Future<void> call({PasswordChange? params}) {
    if (params == null) {
      throw const InvalidCredentialsException();
    }
    if (params.newPassword.length < 6) {
      throw const WeakPasswordException();
    }
    if (params.currentPassword == params.newPassword) {
      throw const AuthUnknownException('New password must be different.');
    }
    return _repository.updatePassword(params);
  }
}
