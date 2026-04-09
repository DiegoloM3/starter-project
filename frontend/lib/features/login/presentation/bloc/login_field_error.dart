import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

enum LoginFieldError {
  emailRequired,
  emailNotValid,
  emailAlreadyRegistered,
  passwordRequired,
  passwordNotValid,
  invalidCredentials,
  unknown;

  String getMessage({required AppLocalizations localizations}) =>
      switch (this) {
        LoginFieldError.emailRequired =>
          localizations.login_field_email_required,
        LoginFieldError.emailNotValid =>
          localizations.login_field_email_not_valid,
        LoginFieldError.emailAlreadyRegistered =>
          localizations.login_field_email_already_registered,
        LoginFieldError.passwordRequired =>
          localizations.login_field_password_required,
        LoginFieldError.passwordNotValid =>
          localizations.login_field_password_not_valid,
        LoginFieldError.invalidCredentials =>
          localizations.login_field_invalid_credentials,
        LoginFieldError.unknown => localizations.login_field_unknown_error,
      };
}

extension LoginFieldsErrorExtensions on List<LoginFieldError> {
  String? getEmailError({required AppLocalizations localizations}) {
    if (contains(LoginFieldError.emailRequired)) {
      return LoginFieldError.emailRequired
          .getMessage(localizations: localizations);
    }
    if (contains(LoginFieldError.emailNotValid)) {
      return LoginFieldError.emailNotValid
          .getMessage(localizations: localizations);
    }
    if (contains(LoginFieldError.emailAlreadyRegistered)) {
      return LoginFieldError.emailAlreadyRegistered
          .getMessage(localizations: localizations);
    }

    return null;
  }

  String? getPasswordError({required AppLocalizations localizations}) {
    if (contains(LoginFieldError.passwordRequired)) {
      return LoginFieldError.passwordRequired
          .getMessage(localizations: localizations);
    }
    if (contains(LoginFieldError.passwordNotValid)) {
      return LoginFieldError.passwordNotValid
          .getMessage(localizations: localizations);
    }
    if (contains(LoginFieldError.invalidCredentials)) {
      return LoginFieldError.invalidCredentials
          .getMessage(localizations: localizations);
    }
    return null;
  }
}
