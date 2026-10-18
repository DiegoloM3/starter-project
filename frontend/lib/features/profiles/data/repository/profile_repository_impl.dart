import '../../../../core/resources/data_state.dart';
import '../../../../shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/params/update_profile_params.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/remote/follow_remote_data_source.dart';
import '../data_sources/remote/user_photo_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserProfileRemoteDataSource _profileDataSource;
  final FollowRemoteDataSource _followDataSource;
  final UserPhotoRemoteDataSource _photoDataSource;

  ProfileRepositoryImpl(this._profileDataSource, this._followDataSource, this._photoDataSource);

  @override
  Future<DataState<UserEntity>> getProfile(String uid) {
    return runAsDataState(() async => (await _profileDataSource.getProfile(uid)).toEntity());
  }

  /// Both counts are requested at the same time.
  @override
  Future<DataState<FollowStats>> getFollowStats(String uid) {
    return runAsDataState(() async {
      // Future.wait rethrows the original exception; a record's `wait` would wrap it in an Error.
      final counts = await Future.wait([_followDataSource.countFollowers(uid), _followDataSource.countFollowing(uid)]);
      return FollowStats(followers: counts[0], following: counts[1]);
    });
  }

  @override
  Future<DataState<bool>> isFollowing(String uid) => runAsDataState(() => _followDataSource.isFollowing(uid));

  @override
  Future<DataState<void>> follow(String uid) => runAsDataState(() => _followDataSource.follow(uid));

  @override
  Future<DataState<void>> unfollow(String uid) => runAsDataState(() => _followDataSource.unfollow(uid));

  @override
  Future<DataState<List<String>>> getFollowedUserIds() => runAsDataState(_followDataSource.getFollowedUserIds);

  /// A new photo is uploaded first, because the profile must be saved with its URL. The old
  /// photo is deleted only after the profile points to the new one.
  @override
  Future<DataState<UserEntity>> updateProfile(UpdateProfileParams params) {
    return runAsDataState(() async {
      final uid = _photoDataSource.signedInUserId;
      final oldPhotoURL = (await _profileDataSource.getProfile(uid)).photoURL;
      final newPhoto = params.newPhoto;
      final photoURL = newPhoto == null ? oldPhotoURL : await _photoDataSource.uploadPhoto(uid, newPhoto);
      await _profileDataSource.updateProfile(
        uid,
        firstName: params.firstName,
        lastName: params.lastName,
        bio: params.bio,
        photoURL: photoURL,
      );
      if (oldPhotoURL != null && photoURL != oldPhotoURL) await _photoDataSource.deletePhoto(oldPhotoURL);
      return (await _profileDataSource.getProfile(uid)).toEntity();
    });
  }
}
