import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../articles/presentation/bloc/articles/articles_cubit.dart';
import '../../../../auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../../auth/presentation/bloc/auth/auth_state.dart';
import '../../bloc/user_profile/user_profile_cubit.dart';
import '../../bloc/user_profile/user_profile_state.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/profile_content.dart';

/// Profile of any user, opened from an article or a comment. Users cannot follow themselves,
/// so the follow button is hidden on their own profile.
class UserProfileScreen extends StatelessWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final userName = context.select((UserProfileCubit cubit) => cubit.state.user?.fullName);
    return Scaffold(
      appBar: AppBar(title: Text(userName ?? '')),
      body: ProfileContent(action: _isOwnProfile(context) ? null : const _FollowAction()),
    );
  }

  bool _isOwnProfile(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    return authState is AuthAuthenticated && authState.user.uid == uid;
  }
}

class _FollowAction extends StatelessWidget {
  const _FollowAction();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserProfileCubit, UserProfileState, bool>(
      selector: (state) => state.isFollowing,
      builder: (context, isFollowing) => FollowButton(isFollowing: isFollowing, onPressed: () => _toggle(context)),
    );
  }

  /// The "following" section of the news tab depends on who the user follows.
  Future<void> _toggle(BuildContext context) async {
    final articlesCubit = context.read<ArticlesCubit>();
    await context.read<UserProfileCubit>().toggleFollow();
    articlesCubit.load();
  }
}
