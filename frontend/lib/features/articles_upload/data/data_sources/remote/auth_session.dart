import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/auth_service.dart';

class AuthSession implements AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthSession(this._auth, {GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  @override
  String? get currentUid => _auth.currentUser?.uid;
  @override
  String? get displayName => _auth.currentUser?.displayName;
  @override
  String? get photoURL => _auth.currentUser?.photoURL;
  @override
  String? get email => _auth.currentUser?.email;
  @override
  bool get isSignedIn => _auth.currentUser != null;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  @override
  bool get isGoogleUser => !isAnonymous && email != null;

  @override
  Future<String> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user!.uid;
  }

  @override
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;
    final result = await _auth.signInAnonymously();
    return result.user!.uid;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
