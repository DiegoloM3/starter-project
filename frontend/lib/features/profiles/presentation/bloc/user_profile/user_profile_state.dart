import 'package:equatable/equatable.dart';

import '../../../../../shared/users/domain/entities/user.dart';
import '../../../../articles/domain/entities/article.dart';
import '../../../domain/entities/follow_stats.dart';

enum UserProfileStatus { initial, loading, success, failure }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserEntity? user;
  final FollowStats? stats;

  /// Whether the signed in user follows this user.
  final bool isFollowing;

  /// Newest first.
  final List<ArticleEntity> articles;

  final bool followFailed;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.stats,
    this.isFollowing = false,
    this.articles = const [],
    this.followFailed = false,
  });

  /// [followFailed] is reset unless it is given, so it is only reported once.
  UserProfileState copyWith({
    UserProfileStatus? status,
    FollowStats? stats,
    bool? isFollowing,
    bool followFailed = false,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user,
      stats: stats ?? this.stats,
      isFollowing: isFollowing ?? this.isFollowing,
      articles: articles,
      followFailed: followFailed,
    );
  }

  @override
  List<Object?> get props => [status, user, stats, isFollowing, articles, followFailed];
}
