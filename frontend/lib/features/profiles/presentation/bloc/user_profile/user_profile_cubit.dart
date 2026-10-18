import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../articles/domain/usecases/get_articles_by_authors.dart';
import '../../../domain/usecases/follow_user.dart';
import '../../../domain/usecases/get_follow_stats.dart';
import '../../../domain/usecases/get_user_profile.dart';
import '../../../domain/usecases/is_following.dart';
import '../../../domain/usecases/unfollow_user.dart';
import 'user_profile_state.dart';

/// Profile of any user, including the signed in one.
class UserProfileCubit extends Cubit<UserProfileState> {
  final String _uid;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetFollowStatsUseCase _getFollowStatsUseCase;
  final IsFollowingUseCase _isFollowingUseCase;
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;
  final GetArticlesByAuthorsUseCase _getArticlesByAuthorsUseCase;

  UserProfileCubit(
    this._uid,
    this._getUserProfileUseCase,
    this._getFollowStatsUseCase,
    this._isFollowingUseCase,
    this._followUserUseCase,
    this._unfollowUserUseCase,
    this._getArticlesByAuthorsUseCase,
  ) : super(const UserProfileState());

  /// The four requests run at the same time. Only the profile and the stats are required:
  /// the profile is still shown if its articles cannot be loaded.
  Future<void> load() async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    final profileRequest = _getUserProfileUseCase(_uid);
    final statsRequest = _getFollowStatsUseCase(_uid);
    final isFollowingRequest = _isFollowingUseCase(_uid);
    final articlesRequest = _getArticlesByAuthorsUseCase([_uid]);

    final profile = await profileRequest;
    final stats = await statsRequest;
    if (profile is DataFailed || stats is DataFailed) {
      emit(state.copyWith(status: UserProfileStatus.failure));
      return;
    }
    emit(
      UserProfileState(
        status: UserProfileStatus.success,
        user: profile.data,
        stats: stats.data,
        isFollowing: (await isFollowingRequest).data ?? false,
        articles: (await articlesRequest).data ?? const [],
      ),
    );
  }

  /// Shows the change at once and restores the previous state if it fails.
  Future<void> toggleFollow() async {
    final previousState = state;
    final willFollow = !state.isFollowing;
    emit(state.copyWith(isFollowing: willFollow, stats: state.stats?.withFollower(isFollowing: willFollow)));

    final result = willFollow ? await _followUserUseCase(_uid) : await _unfollowUserUseCase(_uid);
    if (result is DataFailed) emit(previousState.copyWith(followFailed: true));
  }
}
