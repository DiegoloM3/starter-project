import 'package:news_app_clean_architecture/core/util/value_equality.dart';

import 'credentials_rules.dart';

/// Account that a journalist is filling in the registration form.
class RegistrationDraftEntity with ValueEquality {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegistrationDraftEntity({
    this.name = '',
    this.email = '',
    this.password = '',
    this.passwordConfirmation = '',
  });

  RegistrationDraftEntity copyWith({
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) {
    return RegistrationDraftEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }

  /// The name is shown as the author of the journalist's articles.
  CredentialsError? get nameError {
    if (name.trim().isEmpty) return CredentialsError.blank;
    if (name.trim().length > CredentialsRules.maxNameLength) return CredentialsError.tooLong;
    return null;
  }

  CredentialsError? get emailError => CredentialsRules.findEmailError(email);

  CredentialsError? get passwordError {
    if (password.isEmpty) return CredentialsError.blank;
    if (password.length < CredentialsRules.minPasswordLength) return CredentialsError.tooShort;
    return null;
  }

  CredentialsError? get passwordConfirmationError {
    if (passwordConfirmation.isEmpty) return CredentialsError.blank;
    if (passwordConfirmation != password) return CredentialsError.mismatch;
    return null;
  }

  bool get isValid => [nameError, emailError, passwordError, passwordConfirmationError].every((error) => error == null);

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

/// Thrown when trying to register with a [RegistrationDraftEntity] that breaks its rules.
class InvalidRegistrationException implements Exception {
  final RegistrationDraftEntity draft;

  const InvalidRegistrationException(this.draft);
}
