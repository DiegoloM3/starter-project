import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordResetEmail({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._googleSignIn,
  );

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchUserModel(credential.user!.uid);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final now = DateTime.now();
    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      role: 'reader',
      preferredCategories: const [],
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());
    } catch (e) {
      await credential.user?.delete();
      rethrow;
    }
    return userModel;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(oauthCredential);
    final user = userCredential.user!;
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? googleUser.displayName ?? '',
        photoURL: user.photoURL,
        role: 'reader',
        preferredCategories: const [],
        onboardingCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());
      return userModel;
    }

    return _fetchUserModel(user.uid);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _fetchUserModel(user.uid);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromFirestore(doc);
  }
}
