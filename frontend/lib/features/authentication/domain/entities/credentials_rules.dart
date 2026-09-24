import 'auth_failures.dart';

/// Rules an email and a password must satisfy before the app bothers the
/// backend with them.
///
/// They live here, shared by the params classes, instead of on an entity:
/// `AppUserEntity` deliberately never holds a password, so there is no entity
/// these rules could belong to.
abstract final class CredentialsRules {
  /// Firebase itself only requires 6 characters. Eight is the shortest
  /// password this app is willing to create.
  static const int passwordMinLength = 8;

  /// Deliberately permissive: the address is only ever confirmed by the
  /// backend actually reaching it, so anything stricter than "looks like an
  /// address" would reject valid mailboxes for no gain.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static List<CredentialsValidationError> validateEmail(String email) {
    final trimmed = email.trim();

    if (trimmed.isEmpty) {
      return const [CredentialsValidationError.emailRequired];
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      return const [CredentialsValidationError.emailMalformed];
    }

    return const [];
  }

  /// Rules for a password being *created*. Signing in does not apply them:
  /// an account made before the rules changed must still be able to get in.
  static List<CredentialsValidationError> validateNewPassword(
    String password,
  ) {
    if (password.isEmpty) {
      return const [CredentialsValidationError.passwordRequired];
    }
    if (password.length < passwordMinLength) {
      return const [CredentialsValidationError.passwordTooShort];
    }

    return const [];
  }
}
