import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

/// Convenient extensions on [BuildContext] for accessing theme and media.
extension BuildContextExtensions on BuildContext {
  /// Shorthand for [AppLocalizations.of].
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Shorthand for [Theme.of].
  ThemeData get theme => Theme.of(this);

  /// Shorthand for [Theme.of().textTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Shorthand for [Theme.of().colorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Shorthand for [MediaQuery.sizeOf].
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Shorthand for screen width.
  double get screenWidth => screenSize.width;

  /// Shorthand for screen height.
  double get screenHeight => screenSize.height;

  /// Resolves known localization keys while preserving plain strings.
  String localizeText(String value) {
    final translated = switch (value) {
      AuthErrorKeys.userNotFound => l10n.authUserNotFound,
      AuthErrorKeys.wrongPassword => l10n.authWrongPassword,
      AuthErrorKeys.invalidEmail => l10n.authInvalidEmail,
      AuthErrorKeys.userDisabled => l10n.authUserDisabled,
      AuthErrorKeys.emailAlreadyInUse => l10n.authEmailAlreadyInUse,
      AuthErrorKeys.weakPassword => l10n.authWeakPassword,
      AuthErrorKeys.operationNotAllowed => l10n.authOperationNotAllowed,
      AuthErrorKeys.userCancelled => l10n.authUserCancelled,
      AuthErrorKeys.tokenExpired => l10n.authTokenExpired,
      AuthErrorKeys.invalidCredentials => l10n.authInvalidCredentials,
      AuthErrorKeys.generic => l10n.authGeneric,
      ServerErrorKeys.generic => l10n.serverGeneric,
      ServerErrorKeys.notFound => l10n.serverNotFound,
      ServerErrorKeys.unauthorized => l10n.serverUnauthorized,
      ServerErrorKeys.forbidden => l10n.serverForbidden,
      ServerErrorKeys.badRequest => l10n.serverBadRequest,
      ServerErrorKeys.tooManyRequests => l10n.serverTooManyRequests,
      ServerErrorKeys.internalError => l10n.serverInternalError,
      ServerErrorKeys.badGateway => l10n.serverBadGateway,
      ServerErrorKeys.serviceUnavailable => l10n.serverServiceUnavailable,
      ServerErrorKeys.profileCreationFailed => l10n.serverProfileCreationFailed,
      NetworkErrorKeys.noConnection => l10n.networkNoConnection,
      NetworkErrorKeys.timeout => l10n.networkTimeout,
      NetworkErrorKeys.generic => l10n.networkGeneric,
      _ => null,
    };

    if (translated != null) {
      return translated;
    }

    if (value.startsWith('.')) {
      return l10n.commonSomethingWentWrong;
    }

    return value;
  }

  /// Shows a [SnackBar] with the given [message].
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(localizeText(message)),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
