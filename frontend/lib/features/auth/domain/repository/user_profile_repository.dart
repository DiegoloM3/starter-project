import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';

/// Profile contract for public `users/{uid}` documents; data layer implements.
abstract interface class UserProfileRepository {
  Future<DataState<void>> createUserProfile(UserProfileEntity profile);

  /// Returns the cached public profile when fresh, otherwise reads it.
  /// Null data means the user simply has no profile document yet.
  Future<DataState<UserProfileEntity?>> getAuthorProfile(String userId);

  /// Uploads a new avatar and returns its download URL (null when
  /// [avatarFile] is null). Uploaded once per save and reused for both
  /// the Auth mirror and the Firestore write.
  Future<DataState<String?>> uploadAvatar(String userId, File? avatarFile);

  Future<DataState<UserProfileEntity>> updateUserProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  });

  /// Drops the cached entry so the next read goes back to Firestore.
  void invalidateAuthorProfile(String userId);
}
