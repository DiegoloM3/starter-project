import 'package:equatable/equatable.dart';

/// How many users follow a user, and how many users they follow.
class FollowStats extends Equatable {
  final int followers;
  final int following;

  const FollowStats({required this.followers, required this.following});

  /// The stats after the signed in user starts or stops following this user.
  FollowStats withFollower({required bool isFollowing}) {
    return FollowStats(followers: followers + (isFollowing ? 1 : -1), following: following);
  }

  @override
  List<Object?> get props => [followers, following];
}
