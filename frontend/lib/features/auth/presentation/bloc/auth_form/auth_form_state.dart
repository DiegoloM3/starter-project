import 'package:equatable/equatable.dart';

import '../../../domain/params/auth_validation.dart';

enum AuthFormStatus { idle, submitting, success, failure }

/// Why a submission failed, when it was not because of the validation errors.
enum AuthFormFailure { invalidCredentials, emailAlreadyInUse, unexpected }

class AuthFormState extends Equatable {
  final AuthFormStatus status;
  final Set<AuthValidationError> validationErrors;
  final AuthFormFailure? failure;

  const AuthFormState({this.status = AuthFormStatus.idle, this.validationErrors = const {}, this.failure});

  bool get isSubmitting => status == AuthFormStatus.submitting;

  @override
  List<Object?> get props => [status, validationErrors, failure];
}
