import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/constants/app_info.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// The masthead: the wordmark set large, the account avatar on the right,
/// and under them the dateline (greeting and today's date in small capitals
/// behind a red square).
class HomeHeader extends StatelessWidget {
  final UserEntity user;
  final DateTime now;
  final VoidCallback onAvatarTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.now,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final words = AppInfo.name.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  words.join('\n').toUpperCase(),
                  style: AppTypography.wordmark.copyWith(color: palette.ink),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Semantics(
                button: true,
                label: 'Account',
                child: InkWell(
                  onTap: onAvatarTap,
                  child: UserAvatar(
                    name: user.preferredName,
                    photoUrl: user.photoUrl,
                    size: 40,
                    isCurrentUser: true,
                    ringed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.sm, AppSpacing.screenMargin, AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 7, height: 7, color: palette.primary),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '${RelativeTimeFormatter.greeting(now)}, ${user.firstName}'.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: palette.inkSecondary, letterSpacing: 1.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('/', style: AppTypography.caption.copyWith(color: palette.outlineStrong)),
              ),
              Flexible(
                child: Text(
                  RelativeTimeFormatter.longDate(now).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: palette.inkSecondary, letterSpacing: 1.1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
