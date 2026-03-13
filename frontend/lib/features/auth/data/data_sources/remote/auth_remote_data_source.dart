import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';

/// Abstract class defining the contract for auth remote operations.
abstract class AuthRemoteDataSource {
  /// Signs in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the current authenticated user.
  Future<UserModel?> getCurrentUser();

  /// Stream of auth state changes.
  Stream<UserModel?> get authStateChanges;

  /// Updates user profile in Firestore.
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  /// Changes the user's password.
  /// Requires re-authentication with current password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({required String email});
}

/// Implementation of AuthRemoteDataSource using Firebase.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the users collection.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Sign in failed: No user returned');
    }

    // Fetch user data from Firestore
    final userDoc = await _usersCollection.doc(user.uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc);
    }

    // If no Firestore document exists, create from Firebase Auth user
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    // Update display name in Firebase Auth
    await user.updateDisplayName(displayName);

    // Create user document in Firestore
    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      email: email,
      displayName: displayName,
      photoUrl: null,
      createdAt: now,
      updatedAt: now,
    );

    await _usersCollection.doc(user.uid).set(userModel.toJson());

    return userModel;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    // Try to get user data from Firestore
    final userDoc = await _usersCollection.doc(user.uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc);
    }

    // Fallback to Firebase Auth user
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }

      // Try to get user data from Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      // Fallback to Firebase Auth user
      return UserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (displayName != null) {
      updates['displayName'] = displayName;
      // Also update Firebase Auth profile
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    }

    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      // Also update Firebase Auth profile
      await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
    }

    await _usersCollection.doc(userId).update(updates);

    final updatedDoc = await _usersCollection.doc(userId).get();
    return UserModel.fromFirestore(updatedDoc);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final email = user.email;
    if (email == null) {
      throw Exception('User has no email');
    }

    // Create credential for reauthentication
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Reauthenticate to verify current password
    await user.reauthenticateWithCredential(credential);

    // Update to new password
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
