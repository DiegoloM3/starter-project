import 'package:equatable/equatable.dart';

import '../entities/auth_failures.dart';
import '../entities/credentials_rules.dart';

/// Input of `SignInUseCase`.
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  /// Only checks that something was typed in both fields, and that the
  /// address is shaped like one.
  ///
  /// The length rules of [CredentialsRules.validateNewPassword] are not
  /// applied here on purpose: whether an existing password is long enough is
  /// the backend's business, and rejecting it locally would lock out accounts
  /// created before the rule existed.
  List<CredentialsValidationError> validate() {
    final errors = <CredentialsValidationError>[
      ...CredentialsRules.validateEmail(email),
    ];

    if (password.isEmpty) {
      errors.add(CredentialsValidationError.passwordRequired);
    }

    return errors;
  }

  @override
  List<Object?> get props => [email, password];
}
