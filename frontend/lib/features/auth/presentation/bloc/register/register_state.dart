import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// Every state keeps the [draft], so what the journalist wrote is never lost.
abstract class RegisterState extends Equatable {
  final RegistrationDraftEntity draft;

  const RegisterState(this.draft);

  @override
  List<Object?> get props => [draft];
}

class RegisterEditing extends RegisterState {
  /// Validation errors are only shown after the journalist tries to create the account.
  final bool showsValidationErrors;

  const RegisterEditing(super.draft, {this.showsValidationErrors = false});

  @override
  List<Object?> get props => [draft, showsValidationErrors];
}

class RegisterInProgress extends RegisterState {
  const RegisterInProgress(super.draft);
}

class RegisterSuccess extends RegisterState {
  final UserEntity user;

  const RegisterSuccess(super.draft, this.user);

  @override
  List<Object?> get props => [draft, user];
}

class RegisterFailure extends RegisterState {
  final Exception error;

  const RegisterFailure(super.draft, this.error);

  @override
  List<Object?> get props => [draft, error];
}
