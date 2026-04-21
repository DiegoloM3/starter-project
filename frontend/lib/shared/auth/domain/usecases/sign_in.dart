import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/auth_credentials.dart';

class SignInUseCase implements UseCase<AuthUserEntity, AuthCredentials> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<AuthUserEntity> call({AuthCredentials? params}) {
    if (params == null) {
      throw const InvalidEmailException();
    }
    _validate(params);
    return _repository.signIn(params);
  }

  void _validate(AuthCredentials c) {
    if (c.email.trim().isEmpty || !c.email.contains('@')) {
      throw const InvalidEmailException();
    }
    if (c.password.isEmpty) {
      throw const InvalidCredentialsException();
    }
  }
}
