import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/entities/follow_stats.dart';

void main() {
  const stats = FollowStats(followers: 3, following: 5);

  test('counts one more follower when followed', () {
    expect(stats.withFollower(isFollowing: true), const FollowStats(followers: 4, following: 5));
  });

  test('counts one less follower when unfollowed', () {
    expect(stats.withFollower(isFollowing: false), const FollowStats(followers: 2, following: 5));
  });
}
