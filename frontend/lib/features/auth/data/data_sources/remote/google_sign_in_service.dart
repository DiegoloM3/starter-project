import 'package:google_sign_in/google_sign_in.dart';

/// Abstract data source for Google Sign-In operations.
///
/// Only this file (and its impl) imports `google_sign_in` (AV 1.2.3).
abstract class GoogleSignInService {
  /// Launches the Google sign-in flow. Returns the account or null if cancelled.
  Future<GoogleSignInAccount?> signIn();

  /// Retrieves the OAuth tokens for the signed-in account.
  Future<GoogleSignInAuthentication> getAuthentication(
    GoogleSignInAccount account,
  );

  /// Signs out from Google.
  Future<void> signOut();
}
