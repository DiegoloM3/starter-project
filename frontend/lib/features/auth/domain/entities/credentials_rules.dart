enum CredentialsError { blank, tooLong, invalidEmail, tooShort, mismatch }

/// Rules shared by the sign-in and the registration forms.
class CredentialsRules {
  static const int maxNameLength = 100;
  static const int minPasswordLength = 8;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static CredentialsError? findEmailError(String email) {
    if (email.trim().isEmpty) return CredentialsError.blank;
    if (!_emailPattern.hasMatch(email.trim())) return CredentialsError.invalidEmail;
    return null;
  }
}
