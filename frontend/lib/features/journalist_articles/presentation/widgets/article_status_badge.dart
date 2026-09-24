import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/article_status.dart';

/// Shows whether an article is still private or already public.
///
/// The two states differ in wording as well as colour, and their colours were
/// chosen to stay apart in greyscale, so the distinction survives for a
/// reader who cannot rely on hue.
class ArticleStatusBadge extends StatelessWidget {
  final ArticleStatus status;

  const ArticleStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDraft = status == ArticleStatus.draft;
    final color = isDraft
        ? Theme.of(context).textTheme.labelSmall?.color ?? AppColors.published
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDraft
            ? Theme.of(context).dividerColor.withValues(alpha: 0.5)
            : AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        isDraft
            ? AppLocalizations.of(context).badgeDraft
            : AppLocalizations.of(context).badgePublished,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
