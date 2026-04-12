abstract class AuthService {
  String? get currentUid;
  String? get displayName;
  String? get photoURL;
  String? get email;
  bool get isSignedIn;
  bool get isGoogleUser;

  Future<String> signInWithGoogle();
  Future<String> ensureSignedIn();
  Future<void> signOut();
}
