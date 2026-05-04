/// Static form validators for authentication forms (design D8).
///
/// Hand-rolled validators — no external deps for 2 screens (design D8).
/// Returns null if valid, or an error message string if invalid.
class AuthValidators {
  const AuthValidators._();

  /// Validates an email address.
  ///
  /// Must be non-empty and match a basic RFC 5322-compatible pattern.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Must be non-empty and at least 8 characters long.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  /// Validates a display name.
  ///
  /// Must be non-empty and at least 2 characters long.
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required.';
    }

    if (value.length < 2) {
      return 'Display name must be at least 2 characters.';
    }

    return null;
  }
}
