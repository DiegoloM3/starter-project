import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

enum RegisterFieldError {
  emailRequired,
  emailNotValid,
  emailAlreadyRegistered,
  nameRequired,
  passwordRequired,
  passwordNotValid,
  unknown;

  String getMessage({required AppLocalizations localizations}) =>
      switch (this) {
        RegisterFieldError.emailRequired =>
          localizations.register_field_email_required,
        RegisterFieldError.emailNotValid =>
          localizations.register_field_email_not_valid,
        RegisterFieldError.emailAlreadyRegistered =>
          localizations.register_field_email_already_registered,
        RegisterFieldError.nameRequired =>
          localizations.register_field_name_required,
        RegisterFieldError.passwordRequired =>
          localizations.register_field_password_required,
        RegisterFieldError.passwordNotValid =>
          localizations.register_field_password_not_valid,
        RegisterFieldError.unknown =>
          localizations.register_field_unknown_error,
      };
}

extension RegisterFieldsErrorExtensions on List<RegisterFieldError> {
  String? getEmailError({required AppLocalizations localizations}) {
    if (contains(RegisterFieldError.emailRequired)) {
      return RegisterFieldError.emailRequired
          .getMessage(localizations: localizations);
    }
    if (contains(RegisterFieldError.emailNotValid)) {
      return RegisterFieldError.emailNotValid
          .getMessage(localizations: localizations);
    }
    if (contains(RegisterFieldError.emailAlreadyRegistered)) {
      return RegisterFieldError.emailAlreadyRegistered
          .getMessage(localizations: localizations);
    }

    return null;
  }

  String? getNameError({required AppLocalizations localizations}) {
    if (contains(RegisterFieldError.nameRequired)) {
      return RegisterFieldError.nameRequired
          .getMessage(localizations: localizations);
    }

    return null;
  }

  String? getPasswordError({required AppLocalizations localizations}) {
    if (contains(RegisterFieldError.passwordRequired)) {
      return RegisterFieldError.passwordRequired
          .getMessage(localizations: localizations);
    }
    if (contains(RegisterFieldError.passwordNotValid)) {
      return RegisterFieldError.passwordNotValid
          .getMessage(localizations: localizations);
    }
    return null;
  }
}
