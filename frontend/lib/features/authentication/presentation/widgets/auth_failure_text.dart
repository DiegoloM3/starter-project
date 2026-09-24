import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/auth_failures.dart';
import '../../domain/entities/credentials_rules.dart';
import '../../domain/params/update_display_name_params.dart';

/// Turns an authentication failure into words the person can act on.
class AuthFailureText extends StatelessWidget {
  final Object? failure;

  const AuthFailureText(this.failure, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      messageFor(AppLocalizations.of(context), failure),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  static String messageFor(AppLocalizations l10n, Object? failure) {
    if (failure is CredentialsValidationException) {
      return failure.errors
          .map((error) => messageForValidationError(l10n, error))
          .join('\n');
    }
    if (failure is EmailAlreadyRegisteredException) {
      return l10n.errorEmailInUse;
    }
    if (failure is InvalidCredentialsException) {
      return l10n.errorInvalidCredentials;
    }
    if (failure is NotSignedInException) {
      return l10n.errorNotSignedIn;
    }
    if (failure is TooManyAttemptsException) {
      return l10n.errorTooManyAttempts;
    }
    if (failure is NetworkUnavailableException) {
      return l10n.errorNoConnection;
    }

    return l10n.errorGeneric;
  }

  static String messageForValidationError(
    AppLocalizations l10n,
    CredentialsValidationError error,
  ) {
    switch (error) {
      case CredentialsValidationError.emailRequired:
        return l10n.errorEmailRequired;
      case CredentialsValidationError.emailMalformed:
        return l10n.errorEmailMalformed;
      case CredentialsValidationError.passwordRequired:
        return l10n.errorPasswordRequired;
      case CredentialsValidationError.passwordTooShort:
        return l10n.errorPasswordTooShort(CredentialsRules.passwordMinLength);
      case CredentialsValidationError.passwordsDoNotMatch:
        return l10n.errorPasswordsDiffer;
      case CredentialsValidationError.displayNameInvalid:
        return l10n.errorDisplayName(UpdateDisplayNameParams.maxLength);
    }
  }
}
