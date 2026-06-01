import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserEntity user;
  final int totalPublishedCount;
  final ValueChanged<bool>? onRoleToggled;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.totalPublishedCount,
    this.onRoleToggled,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k Tips';
    }
    return '$count Tips';
  }

  @override
  Widget build(BuildContext context) {
    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surface,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? Text(
                    initials,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTypography.h3,
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.bio,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _TipsCountChip(count: totalPublishedCount, format: _formatCount),
                    const Spacer(),
                    if (onRoleToggled != null)
                      _WriterSwitch(
                        isWriter: user.role == 'writer',
                        onChanged: onRoleToggled!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WriterSwitch extends StatelessWidget {
  final bool isWriter;
  final ValueChanged<bool> onChanged;

  const _WriterSwitch({required this.isWriter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isWriter ? Icons.edit : Icons.menu_book_outlined,
          size: AppSpacing.iconSm,
          color: isWriter ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Switch.adaptive(
          value: isWriter,
          onChanged: onChanged,
          activeThumbColor: AppColors.white,
          activeTrackColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _TipsCountChip extends StatelessWidget {
  final int count;
  final String Function(int) format;

  const _TipsCountChip({required this.count, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        format(count),
        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
