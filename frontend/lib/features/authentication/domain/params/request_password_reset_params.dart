import 'package:equatable/equatable.dart';

import '../entities/auth_failures.dart';
import '../entities/credentials_rules.dart';

/// Input of `RequestPasswordResetUseCase`.
class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams(this.email);

  List<CredentialsValidationError> validate() {
    return CredentialsRules.validateEmail(email);
  }

  @override
  List<Object?> get props => [email];
}
