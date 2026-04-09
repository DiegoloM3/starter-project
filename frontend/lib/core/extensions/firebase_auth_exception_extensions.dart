import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/errors/auth_exception.dart';

extension FirebaseAuthExceptionExtensions on FirebaseAuthException {
  AuthException get parseAuthException => switch (code) {
        'invalid-email' => const InvalidEmailException(),
        'email-already-in-use' => const EmailAlreadyInUseException(),
        'user-disabled' => const UserDisabledException(),
        'user-not-found' => const UserNotFoundException(),
        'wrong-password' => const WrongPasswordException(),
        'too-many-requests' => const TooManyRequestsException(),
        'user-token-expired' => const UserTokenExpiredException(),
        'network-request-failed' => const NetworkRequestFailedException(),
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          const InvalidCredentialException(),
        'operation-not-allowed' => const OperationNotAllowedException(),
        _ => UnknownAuthException(
            message: message ?? 'An unknown error occurred.',
            originalError: this,
          ),
      };
}
