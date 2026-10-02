import 'package:news_app_clean_architecture/core/util/value_equality.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Email and password written in the sign-in form.
class SignInParams with ValueEquality {
  final String email;
  final String password;

  const SignInParams({this.email = '', this.password = ''});

  SignInParams copyWith({String? email, String? password}) {
    return SignInParams(email: email ?? this.email, password: password ?? this.password);
  }

  CredentialsError? get emailError => CredentialsRules.findEmailError(email);

  CredentialsError? get passwordError => password.isEmpty ? CredentialsError.blank : null;

  bool get isValid => emailError == null && passwordError == null;

  @override
  List<Object?> get props => [email, password];
}

/// Thrown when trying to sign in with [SignInParams] that break their rules.
class InvalidSignInException implements Exception {
  final SignInParams params;

  const InvalidSignInException(this.params);
}

class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignInParams? params}) async {
    final signInParams = params!;
    if (!signInParams.isValid) return DataFailed(InvalidSignInException(signInParams));
    return _authRepository.signIn(signInParams.email.trim(), signInParams.password);
  }
}
