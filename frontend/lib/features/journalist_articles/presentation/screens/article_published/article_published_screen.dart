import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/centered_form.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/journalist_article.dart';

/// The one moment in the app worth stopping for.
///
/// Publishing is the only action that makes something public, and a snack bar
/// would let it slip past unnoticed. Saving a draft, which is routine and
/// reversible, gets no screen of its own — the weight of the acknowledgement
/// matches the weight of what happened.
class ArticlePublishedScreen extends StatelessWidget {
  final JournalistArticleEntity article;

  const ArticlePublishedScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Centred while it fits, scrollable the moment it does not. The layout
      // used fixed Spacers until the Spanish translation — a fifth longer
      // than the English — overflowed it on a short screen.
      body: SafeArea(
        child: CenteredForm(
          footer: Column(
            children: [
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/ArticleReader',
                  arguments: article,
                ),
                child: Text(AppLocalizations.of(context).viewArticle),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/MyArticles',
                ),
                child: Text(AppLocalizations.of(context).backToMyArticles),
              ),
            ],
          ),
          children: [
            Column(
              children: [
                const _SuccessMark(),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  AppLocalizations.of(context).articleLiveTitle,
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context).articleLiveMessage,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Which article, not just that one was published: the
                // confirmation is worth more when it shows the thing itself.
                _PublishedPreview(article: article),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A check that draws itself in, rather than one that is simply there.
class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, progress, child) => Transform.scale(
        scale: progress,
        child: child,
      ),
      child: Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_outline,
          size: 46,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _PublishedPreview extends StatelessWidget {
  final JournalistArticleEntity article;

  const _PublishedPreview({required this.article});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: article.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
