import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';

class GoogleIdentityDataSource {
  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  GoogleIdentityDataSource(this._googleSignIn);

  Future<String> requestIdToken() async {
    await _ensureInitialized();
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AccountException(AccountErrorReason.unknown);
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      throw AccountException(_reasonFor(e.code));
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  // google_sign_in 7 requires initialize() exactly once, before any other call.
  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize();
  }

  AccountErrorReason _reasonFor(GoogleSignInExceptionCode code) {
    return switch (code) {
      GoogleSignInExceptionCode.canceled => AccountErrorReason.cancelled,
      // Typically this build's signing key isn't registered in Firebase.
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        AccountErrorReason.methodNotAvailable,
      _ => AccountErrorReason.unknown,
    };
  }
}
