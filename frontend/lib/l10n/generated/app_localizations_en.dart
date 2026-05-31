// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Symmetry News';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get newsNoArticlesFound => 'No articles found';

  @override
  String get authUserNotFound => 'No account was found for that email.';

  @override
  String get authWrongPassword => 'Incorrect password.';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authUserDisabled => 'This account has been disabled.';

  @override
  String get authEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get authWeakPassword => 'Password is too weak.';

  @override
  String get authOperationNotAllowed => 'This sign-in method is not enabled.';

  @override
  String get authUserCancelled => 'Sign-in was cancelled.';

  @override
  String get authTokenExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authInvalidCredentials => 'The provided credentials are invalid.';

  @override
  String get authGeneric => 'Authentication failed. Please try again.';

  @override
  String get authEnterDisplayName => 'Enter your name.';

  @override
  String get authEnterEmail => 'Enter your email address.';

  @override
  String get authEnterPassword => 'Enter your password.';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get serverGeneric => 'The server could not process the request.';

  @override
  String get serverNotFound => 'The requested resource was not found.';

  @override
  String get serverUnauthorized =>
      'You are not authorized to perform this action.';

  @override
  String get serverForbidden =>
      'You do not have permission to access this resource.';

  @override
  String get serverBadRequest => 'The request is invalid.';

  @override
  String get serverTooManyRequests =>
      'Too many requests. Please try again later.';

  @override
  String get serverInternalError => 'An internal server error occurred.';

  @override
  String get serverBadGateway => 'The upstream service is unavailable.';

  @override
  String get serverServiceUnavailable =>
      'The service is temporarily unavailable.';

  @override
  String get serverProfileCreationFailed =>
      'We could not finish creating your profile.';

  @override
  String get networkNoConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String get networkTimeout => 'The request timed out. Please try again.';

  @override
  String get networkGeneric => 'A network error occurred. Please try again.';
}
