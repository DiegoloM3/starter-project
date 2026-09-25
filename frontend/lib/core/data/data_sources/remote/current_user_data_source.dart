import 'package:firebase_auth/firebase_auth.dart';

/// In `core` because both user_articles and account depend on it, and
/// APP_ARCHITECTURE.md only sanctions sharing across features via core/shared.
class CurrentUserDataSource {
  final FirebaseAuth _auth;

  CurrentUserDataSource(this._auth);

  /// Signs in as a guest when there's no user (first launch, or right after
  /// signing out), so every caller always gets a uid to own data with.
  Future<String> ensureSignedIn() async {
    var user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    if (user == null) {
      throw Exception('Could not authenticate');
    }
    return user.uid;
  }
}
