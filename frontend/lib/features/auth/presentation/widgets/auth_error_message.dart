import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';

/// Text shown under a field for each rule the journalist's credentials can break.
extension CredentialsErrorMessage on CredentialsError {
  String get message {
    switch (this) {
      case CredentialsError.blank:
        return 'This field is required';
      case CredentialsError.tooLong:
        return 'This field is too long';
      case CredentialsError.invalidEmail:
        return 'Enter a valid email';
      case CredentialsError.tooShort:
        return 'Use at least ${CredentialsRules.minPasswordLength} characters';
      case CredentialsError.mismatch:
        return 'The passwords do not match';
    }
  }
}

/// Text shown when Firebase Authentication rejects a sign-in or a registration.
extension AuthErrorMessage on AuthError {
  String get message {
    switch (this) {
      case AuthError.wrongEmailOrPassword:
        return 'The email or password is incorrect.';
      case AuthError.emailAlreadyInUse:
        return 'There is already an account with this email.';
      case AuthError.weakPassword:
        return 'Choose a stronger password.';
      case AuthError.invalidEmail:
        return 'Enter a valid email.';
      case AuthError.tooManyAttempts:
        return 'Too many attempts. Please wait a moment and try again.';
      case AuthError.noConnection:
        return 'No connection. Check your internet and try again.';
      case AuthError.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Message for any error of a sign-in or a registration.
String authFailureMessage(Exception error) {
  return error is AuthException ? error.error.message : AuthError.unknown.message;
}
