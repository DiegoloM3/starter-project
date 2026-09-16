import 'package:news_app_clean_architecture/core/resources/failure.dart';

/// Turns a domain [Failure] into the sentence the user reads.
///
/// The domain message is technical and neutral; here it becomes advice in
/// plain words, as the design asks for every error.
abstract final class FailureMessageFormatter {
  static String of(Failure failure) {
    return switch (failure.type) {
      FailureType.network =>
        'Check your internet connection and try again.',
      FailureType.invalidCredentials =>
        "That password isn't right. Check it and try again.",
      FailureType.emailAlreadyInUse =>
        'There is already an account with this email. Sign in instead.',
      FailureType.weakPassword =>
        'That password is too easy to guess. Try a longer one.',
      FailureType.unauthenticated => 'Sign in to continue.',
      FailureType.permissionDenied => "You can't do that with this account.",
      FailureType.notFound => "We couldn't find what you were looking for.",
      FailureType.cancelled => 'Sign-in was cancelled.',
      FailureType.server ||
      FailureType.unknown =>
        'Something went wrong on our side. Please try again.',
      FailureType.validation => failure.message,
    };
  }
}
