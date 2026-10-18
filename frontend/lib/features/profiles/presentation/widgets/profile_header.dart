import 'package:flutter/material.dart';

import '../../../../shared/users/domain/entities/user.dart';
import '../../../../shared/users/presentation/widgets/role_badge.dart';
import '../../../../shared/users/presentation/widgets/user_avatar.dart';
import '../../domain/entities/follow_stats.dart';

/// Photo, name, role, bio and follow counts of a user.
class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final FollowStats? stats;

  const ProfileHeader({super.key, required this.user, this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        UserAvatar(user: user),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        RoleBadge(role: user.role),
        if (user.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(user.bio, textAlign: TextAlign.center, style: textTheme.bodyLarge),
        ],
        if (stats != null) ...[const SizedBox(height: 20), _FollowCounts(stats: stats!)],
      ],
    );
  }
}

class _FollowCounts extends StatelessWidget {
  final FollowStats stats;

  const _FollowCounts({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Count(value: stats.followers, label: stats.followers == 1 ? 'seguidor' : 'seguidores'),
        const SizedBox(height: 32, child: VerticalDivider(width: 48)),
        _Count(value: stats.following, label: 'siguiendo'),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  final int value;
  final String label;

  const _Count({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('$value', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
