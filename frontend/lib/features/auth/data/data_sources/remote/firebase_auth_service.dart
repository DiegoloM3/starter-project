// coverage:ignore-file
// Thin wrapper over the Firebase Auth and Google Sign-In SDKs.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';

/// Talks to Firebase Authentication and Google Sign-In. Errors propagate as
/// the SDK throws them; the repository translates them.
class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService(this._auth, this._googleSignIn);

  /// `userChanges` also fires after a profile edit, unlike `authStateChanges`.
  Stream<UserModel?> authStateChanges() => _auth.userChanges().map(_toModel);

  UserModel? get currentUser => _toModel(_auth.currentUser);

  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _toModel(credential.user)!;
  }

  /// Creates the account and stores the display name on the profile.
  Future<UserModel> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.reload();
    return _toModel(_auth.currentUser ?? user)!;
  }

  Future<UserModel> signInWithGoogle() async {
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'invalid-credential', message: 'Google returned no id token.');
    }
    final credential = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    return _toModel(credential.user)!;
  }

  Future<UserModel> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user', message: 'Nobody is signed in.');
    }
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    await user.reload();
    return _toModel(_auth.currentUser ?? user)!;
  }

  /// Firebase first: that is what flips the session and lets the app move
  /// on. Forgetting the Google account (a network round trip) follows, so
  /// the next Google sign-in shows the account picker again.
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  static UserModel? _toModel(User? user) {
    if (user == null) return null;
    return UserModel.fromRawData(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
