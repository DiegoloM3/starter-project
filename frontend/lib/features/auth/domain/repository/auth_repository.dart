import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// Abstract repository interface for authentication operations.
/// The data layer will implement this interface.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  /// Returns [DataState<UserEntity>] with the user data on success.
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Creates a new user account with email and password.
  /// Returns [DataState<UserEntity>] with the created user data on success.
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the currently authenticated user.
  /// Returns null if no user is signed in.
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Updates the user's profile information.
  Future<DataState<UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Changes the user's password.
  /// Requires the current password for re-authentication.
  Future<DataState<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Sends a password reset email to the given email address.
  Future<DataState<void>> forgotPassword({required String email});
}
