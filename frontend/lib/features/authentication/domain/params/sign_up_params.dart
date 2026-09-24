import 'package:equatable/equatable.dart';

import '../entities/auth_failures.dart';
import '../entities/credentials_rules.dart';

/// Input of `SignUpUseCase`.
///
/// [displayName] is optional: an account with none publishes under the part
/// of its address before the `@` (see `AppUserEntity.authorName`).
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.displayName = '',
  });

  List<CredentialsValidationError> validate() {
    final errors = <CredentialsValidationError>[
      ...CredentialsRules.validateEmail(email),
      ...CredentialsRules.validateNewPassword(password),
    ];

    if (password.isNotEmpty && password != confirmPassword) {
      errors.add(CredentialsValidationError.passwordsDoNotMatch);
    }

    return errors;
  }

  @override
  List<Object?> get props => [email, password, confirmPassword, displayName];
}
