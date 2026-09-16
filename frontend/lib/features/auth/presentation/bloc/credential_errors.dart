import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

/// Splits the validation errors of a credentials form by field, so each
/// text field shows only the first problem that concerns it.
abstract final class CredentialErrors {
  static const Set<CredentialValidationError> _displayName = {
    CredentialValidationError.emptyDisplayName,
    CredentialValidationError.shortDisplayName,
    CredentialValidationError.longDisplayName,
  };

  static const Set<CredentialValidationError> _email = {
    CredentialValidationError.emptyEmail,
    CredentialValidationError.invalidEmail,
  };

  static const Set<CredentialValidationError> _password = {
    CredentialValidationError.emptyPassword,
    CredentialValidationError.shortPassword,
  };

  static CredentialValidationError? forDisplayName(
    List<CredentialValidationError> errors,
  ) =>
      _firstOf(errors, _displayName);

  static CredentialValidationError? forEmail(
    List<CredentialValidationError> errors,
  ) =>
      _firstOf(errors, _email);

  static CredentialValidationError? forPassword(
    List<CredentialValidationError> errors,
  ) =>
      _firstOf(errors, _password);

  static CredentialValidationError? _firstOf(
    List<CredentialValidationError> errors,
    Set<CredentialValidationError> group,
  ) {
    for (final error in errors) {
      if (group.contains(error)) return error;
    }
    return null;
  }
}
