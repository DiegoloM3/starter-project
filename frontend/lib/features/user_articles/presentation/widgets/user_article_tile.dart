import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/relative_time.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// One of your articles as a card: photo, headline, summary, and a footer
/// with when it was last touched and how long it takes to read. No byline:
/// in My Articles it's always you.
class UserArticleTile extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback onTap;

  /// Position in the list, used only to stagger the entrance animation --
  /// each tile in ListView.builder mounts (and so animates in) once, the
  /// first time it scrolls into view, not on every rebuild. Capped so a
  /// tile far down a long list doesn't wait increasingly longer.
  final int index;

  const UserArticleTile({
    super.key,
    required this.article,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: colorScheme.outlineVariant),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            // IntrinsicHeight lets the text column stretch to the photo's
            // height, so the footer sits on the card's bottom edge instead
            // of floating right under a short summary.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: AppImage(url: article.thumbnailURL),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _Details(article: article)),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 40 * index.clamp(0, 8)))
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

class _Details extends StatelessWidget {
  final UserArticleEntity article;

  const _Details({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final untitled = article.title.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.isDraft) ...[
          const _DraftBadge(),
          const SizedBox(height: 6),
        ],
        Text(
          untitled ? context.l10n.untitledDraft : article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: untitled ? theme.colorScheme.onSurfaceVariant : null,
            fontStyle: untitled ? FontStyle.italic : null,
          ),
        ),
        if (article.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            article.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        const Spacer(),
        const SizedBox(height: 8),
        _Footer(article: article),
      ],
    );
  }
}

/// "4 min read ........ (clock) 3 h ago" -- the date itself once it was
/// more than a day ago. Last edited, not first saved: for a draft that's
/// the work in progress, and for a published article its latest version.
class _Footer extends StatelessWidget {
  final UserArticleEntity article;

  const _Footer({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.readingTime(article.readingMinutes),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Icon(Icons.schedule,
            size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          relativeTimeOrDate(
            article.updatedAt,
            context.l10n,
            showDateAfter: const Duration(days: 1),
          ),
          style: style,
        ),
      ],
    );
  }
}

class _DraftBadge extends StatelessWidget {
  const _DraftBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        context.l10n.draftBadge.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}
