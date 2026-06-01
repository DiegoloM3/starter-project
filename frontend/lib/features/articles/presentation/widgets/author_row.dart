import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class AuthorRow extends StatelessWidget {
  final UserEntity author;
  final int readTimeMinutes;
  final bool? isSaved;
  final VoidCallback? onToggleSave;

  const AuthorRow({
    super.key,
    required this.author,
    required this.readTimeMinutes,
    this.isSaved,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: AppSpacing.avatarSizeSm / 2,
          backgroundColor: AppColors.surface,
          backgroundImage: author.avatarUrl.isNotEmpty
              ? NetworkImage(author.avatarUrl)
              : null,
          child: author.avatarUrl.isEmpty
              ? Text(
                  author.name.isNotEmpty ? author.name[0].toUpperCase() : '?',
                  style: AppTypography.label.copyWith(color: AppColors.textPrimary),
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                style: AppTypography.label.copyWith(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (author.bio.isNotEmpty)
                Text(
                  author.bio,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '$readTimeMinutes min',
            style: AppTypography.caption,
          ),
        ),
        if (onToggleSave != null) ...[
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onToggleSave,
            child: Icon(
              (isSaved ?? false) ? Icons.bookmark : Icons.bookmark_outline,
              color: (isSaved ?? false) ? AppColors.primary : AppColors.textSecondary,
              size: AppSpacing.iconMd,
            ),
          ),
        ],
      ],
    );
  }
}
