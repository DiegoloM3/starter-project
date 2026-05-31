import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/user_entity.dart';

/// Abstract repository interface for authentication operations.
///
/// Remote operations return [DataState<T>] to support proper error handling
/// and result pattern matching. Local operations return results directly.
abstract interface class AuthRepository {
  const AuthRepository();

  /// Signs in with email and password credentials.
  ///
  /// Returns [DataSuccess] with user on success.
  /// Throws [AuthFailure] or [ServerFailure] on error.
  Future<DataState<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  ///
  /// Also persists the user profile to Firestore.
  /// Returns [DataSuccess] with user on success.
  /// Throws [AuthFailure] or [ServerFailure] on error.
  Future<DataState<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in with Google account.
  ///
  /// Also persists the user profile to Firestore if new user.
  /// Returns [DataSuccess] with user on success.
  /// Throws [AuthFailure] or [ServerFailure] on error.
  Future<DataState<UserEntity>> signInWithGoogle();

  /// Signs out the current user from all providers.
  ///
  /// Returns [DataSuccess<void>] on success.
  /// Throws [AuthFailure] on error.
  Future<DataState<void>> signOut();

  /// Returns the currently authenticated user, or null.
  ///
  /// This is a local, synchronous operation and does not use [DataState].
  Future<UserEntity?> getCurrentUser();

  /// Streams authentication state changes as [AuthStatus] sealed type.
  ///
  /// This is a stream of state changes and does not use [DataState].
  Stream<AuthStatus> watchAuthStatus();
}
