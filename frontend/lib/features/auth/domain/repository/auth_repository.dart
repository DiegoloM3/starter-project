import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';

/// Auth contract used by use cases; implemented in the data layer.
abstract interface class AuthRepository {
  Future<DataState<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<DataState<UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<DataState<void>> logout();

  /// Deletes the currently signed-in Firebase Auth user. Used only to roll
  /// back registration when the profile write fails.
  Future<DataState<void>> deleteCurrentUser();

  /// Mirrors the public profile onto the Firebase Auth user so the auth
  /// state carries the fresh display name and photo URL.
  Future<DataState<UserEntity?>> updateCurrentUserProfile({
    String? displayName,
    String? photoUrl,
  });

  Future<DataState<UserEntity?>> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
