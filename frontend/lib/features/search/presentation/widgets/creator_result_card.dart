import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class CreatorResultCard extends StatelessWidget {
  final UserEntity creator;

  const CreatorResultCard({
    super.key,
    required this.creator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            backgroundImage: creator.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(creator.avatarUrl)
                : null,
            child: creator.avatarUrl.isEmpty
                ? Text(
                    creator.name.isNotEmpty
                        ? creator.name[0].toUpperCase()
                        : '?',
                    style: AppTypography.body
                        .copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  creator.bio,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Follow',
              style: AppTypography.label
                  .copyWith(color: AppColors.textOnDark),
            ),
          ),
        ],
      ),
    );
  }
}
