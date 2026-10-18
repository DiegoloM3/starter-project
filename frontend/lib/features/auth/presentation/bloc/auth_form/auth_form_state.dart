import 'package:equatable/equatable.dart';

import '../../../domain/params/auth_validation.dart';

enum AuthFormStatus { idle, submitting, success, failure }

class AuthFormState extends Equatable {
  final AuthFormStatus status;

  /// Empty on a failure means that something unexpected happened.
  final Set<AuthValidationError> validationErrors;

  const AuthFormState({this.status = AuthFormStatus.idle, this.validationErrors = const {}});

  bool get isSubmitting => status == AuthFormStatus.submitting;

  @override
  List<Object?> get props => [status, validationErrors];
}
