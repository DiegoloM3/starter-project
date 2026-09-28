import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_profile_firebase_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_profile.model.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';

class _CachedProfile {
  final UserProfileEntity profile;
  final DateTime expiresAt;

  _CachedProfile(this.profile, this.expiresAt);
}

@LazySingleton(as: UserProfileRepository)
/// [UserProfileRepository] implementation with a 10-minute in-memory cache.
class UserProfileRepositoryImpl implements UserProfileRepository {
  static final _log = Logger('UserProfileRepositoryImpl');

  static const Duration _cacheTtl = kAuthorProfileCacheTtl;

  final UserProfileFirebaseService _service;
  final Map<String, _CachedProfile> _cache = {};

  UserProfileRepositoryImpl(this._service);

  @override
  Future<DataState<void>> createUserProfile(UserProfileEntity profile) async {
    try {
      await _service
          .createUserProfile(UserProfileModel.fromEntity(profile));
      _cache[profile.id] = _CachedProfile(profile, _expiresAt());
      return const DataSuccess(null);
    } catch (e, st) {
      _log.severe('createUserProfile → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<UserProfileEntity?>> getAuthorProfile(
      String userId) async {
    try {
      final cached = _cache[userId];
      if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
        return DataSuccess(cached.profile);
      }
      final profile = await _service.getUserProfile(userId);
      if (profile != null) {
        _cache[userId] = _CachedProfile(profile, _expiresAt());
      }
      return DataSuccess(profile);
    } catch (e, st) {
      _log.severe('getAuthorProfile → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<String?>> uploadAvatar(
      String userId, File? avatarFile) async {
    try {
      final url = await _service.uploadAvatar(userId, avatarFile);
      return DataSuccess(url);
    } catch (e, st) {
      _log.severe('uploadAvatar → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  Future<DataState<UserProfileEntity>> updateUserProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final existing = await _service.getUserProfile(userId);
      final profile = UserProfileModel(
        id: userId,
        displayName: displayName,
        photoUrl: photoUrl ?? existing?.photoUrl,
      );
      await _service.saveUserProfile(profile);
      invalidateAuthorProfile(userId);
      return DataSuccess(profile);
    } catch (e, st) {
      _log.severe('updateUserProfile → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  void invalidateAuthorProfile(String userId) {
    _cache.remove(userId);
  }

  DateTime _expiresAt() => DateTime.now().add(_cacheTtl);
}
