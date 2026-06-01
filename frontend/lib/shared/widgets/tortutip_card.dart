import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

class TortuArticleCard extends StatelessWidget {
  final String title;
  final String? authorName;
  final String? readTime;
  final String? coverUrl;
  final VoidCallback? onTap;

  const TortuArticleCard({
    super.key,
    required this.title,
    this.authorName,
    this.readTime,
    this.coverUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.articleCard,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coverUrl != null && coverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.network(
                  coverUrl!,
                  height: AppSpacing.categoryCardHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: AppSpacing.categoryCardHeight,
                    decoration: AppDecorations.coverImagePlaceholder,
                  ),
                ),
              ),
            if (coverUrl != null && coverUrl!.isNotEmpty) const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.h4),
            if (authorName != null || readTime != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (authorName != null)
                    Text(authorName!, style: AppTypography.bodySm),
                  if (authorName != null && readTime != null)
                    Text(
                      '  ·  ',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  if (readTime != null)
                    Text(readTime!, style: AppTypography.bodySm),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TortuProfileCard extends StatelessWidget {
  final String name;
  final String? bio;
  final String? avatarUrl;
  final Widget? trailing;

  const TortuProfileCard({
    super.key,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.whiteCard,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.avatarSizeMd / 2,
            backgroundColor: AppColors.surface,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTypography.h4,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.h4),
                if (bio != null)
                  Text(bio!, style: AppTypography.bodySm),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
