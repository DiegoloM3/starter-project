import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';

class FeedCardDetail extends StatelessWidget {
  // Closest token: avatarSizeSm (32) / 2 = 16; accepts minor visual delta from literal 18
  static const double _authorAvatarRadius = AppSpacing.avatarSizeSm / 2;

  final ArticleEntity article;

  const FeedCardDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            article.body,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: _authorAvatarRadius,
                backgroundColor: AppColors.surface,
                backgroundImage: article.authorAvatarUrl.isNotEmpty
                    ? NetworkImage(article.authorAvatarUrl)
                    : null,
                child: article.authorAvatarUrl.isEmpty
                    ? Text(
                        article.authorName.isNotEmpty
                            ? article.authorName[0].toUpperCase()
                            : '?',
                        style: AppTypography.label
                            .copyWith(color: AppColors.textSecondary),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.authorName.isNotEmpty
                        ? article.authorName
                        : l10n.feedCardUnknownAuthor,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.feedCardReadTime(article.readTimeMinutes),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TortuPrimaryButton(
            label: l10n.feedCardReadMore,
            onTap: () => context.push(AppRoutes.articleDetailPath(article.id)),
          ),
        ],
      ),
    );
  }
}
