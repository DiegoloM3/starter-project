import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Implementation of AuthRepository using Firebase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return DataSuccess(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return DataFailed(_mapFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(Exception('Sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return DataSuccess(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return DataFailed(_mapFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(Exception('Sign up failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges;
  }

  @override
  Future<DataState<UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final currentUser = await _remoteDataSource.getCurrentUser();
      if (currentUser == null || currentUser.id == null) {
        return DataFailed(Exception('No authenticated user'));
      }

      final updatedUser = await _remoteDataSource.updateProfile(
        userId: currentUser.id!,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return DataSuccess(updatedUser);
    } catch (e) {
      return DataFailed(Exception('Update profile failed: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const DataSuccess(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return DataFailed(_mapFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(Exception('Change password failed: ${e.toString()}'));
    }
  }

  /// Maps Firebase Auth exceptions to user-friendly messages.
  Exception _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'weak-password':
        return Exception('Password is too weak. Use at least 6 characters.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'requires-recent-login':
        return Exception(
            'Please sign out and sign in again before changing your password.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception(e.message ?? 'Authentication error occurred.');
    }
  }

  @override
  Future<DataState<void>> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      return const DataSuccess(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return DataFailed(_mapFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(
          Exception('Failed to send reset email: ${e.toString()}'));
    }
  }
}
