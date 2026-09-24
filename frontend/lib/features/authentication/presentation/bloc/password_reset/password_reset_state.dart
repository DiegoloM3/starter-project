import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_failures.dart';

enum PasswordResetStatus { editing, sending, sent, failure }

/// UI state of the "forgot my password" screen.
class PasswordResetState extends Equatable {
  final PasswordResetStatus status;
  final List<CredentialsValidationError> validationErrors;
  final Object? error;

  const PasswordResetState({
    this.status = PasswordResetStatus.editing,
    this.validationErrors = const [],
    this.error,
  });

  bool get isSending => status == PasswordResetStatus.sending;

  bool get wasSent => status == PasswordResetStatus.sent;

  @override
  List<Object?> get props => [status, validationErrors, error];
}
