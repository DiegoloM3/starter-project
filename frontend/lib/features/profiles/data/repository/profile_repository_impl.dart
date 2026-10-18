import '../../../../core/resources/data_state.dart';
import '../../../../shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/remote/follow_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserProfileRemoteDataSource _profileDataSource;
  final FollowRemoteDataSource _followDataSource;

  ProfileRepositoryImpl(this._profileDataSource, this._followDataSource);

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
}
