import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';

/// Every state keeps the [params], so what the journalist wrote is never lost.
abstract class SignInState extends Equatable {
  final SignInParams params;

  const SignInState(this.params);

  @override
  List<Object?> get props => [params];
}

class SignInEditing extends SignInState {
  /// Validation errors are only shown after the journalist tries to sign in.
  final bool showsValidationErrors;

  const SignInEditing(super.params, {this.showsValidationErrors = false});

  @override
  List<Object?> get props => [params, showsValidationErrors];
}

class SignInInProgress extends SignInState {
  const SignInInProgress(super.params);
}

class SignInSuccess extends SignInState {
  final UserEntity user;

  const SignInSuccess(super.params, this.user);

  @override
  List<Object?> get props => [params, user];
}

class SignInFailure extends SignInState {
  final Exception error;

  const SignInFailure(super.params, this.error);

  @override
  List<Object?> get props => [params, error];
}
