import '../../../../core/resources/data_state.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../entities/follow_stats.dart';

/// Public profiles and follows. Any user can follow any other user.
abstract class ProfileRepository {
  Future<DataState<UserEntity>> getProfile(String uid);

  Future<DataState<FollowStats>> getFollowStats(String uid);

  /// Whether the signed in user follows [uid].
  Future<DataState<bool>> isFollowing(String uid);

  Future<DataState<void>> follow(String uid);

  Future<DataState<void>> unfollow(String uid);

  /// Users followed by the signed in user.
  Future<DataState<List<String>>> getFollowedUserIds();
}
