import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/journalist_article.dart';
import 'article_status_badge.dart';

/// One of the journalist's own articles.
///
/// Unlike [PublishedArticleTile], which only leads somewhere, this row is a
/// place of work: it says what state the article is in and offers every
/// action that applies to it, spelled out in words rather than hidden behind
/// a menu or a swipe.
class JournalistArticleTile extends StatelessWidget {
  final JournalistArticleEntity article;
  final ValueChanged<JournalistArticleEntity> onEdit;
  final ValueChanged<JournalistArticleEntity> onPublish;
  final ValueChanged<JournalistArticleEntity> onDelete;

  const JournalistArticleTile({
    super.key,
    required this.article,
    required this.onEdit,
    required this.onPublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(context),
            const SizedBox(height: AppSpacing.md),
            _buildSummary(context),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),
            _buildActionRow(context),
          ],
        ),
      ),
    );
  }

  /// What state the article is in, and how many people have read it.
  Widget _buildStatusRow(BuildContext context) {
    return Row(
      children: [
        ArticleStatusBadge(article.status),
        const Spacer(),
        if (article.isPublished)
          Text(
            AppLocalizations.of(
              context,
            ).viewsCount(_compactCount(article.viewCount)),
            style: Theme.of(context).textTheme.labelSmall,
          ),
      ],
    );
  }

  /// The article itself: its headline, and its standfirst when it has one.
  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (article.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            article.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Every action that applies, spelled out in words rather than hidden
  /// behind a menu or a swipe. "Publish" only appears on a draft, because it
  /// means nothing on an article that is already out.
  Widget _buildActionRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            _timestampLabel(context),
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (article.isDraft)
          TextButton(
            onPressed: () => onPublish(article),
            child: Text(l10n.publish),
          ),
        TextButton(
          onPressed: () => onEdit(article),
          child: Text(l10n.edit),
        ),
        TextButton(
          onPressed: () => onDelete(article),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: Text(l10n.delete),
        ),
      ],
    );
  }

  /// A published article says when readers got it; a draft says when its
  /// author last touched it. They are different facts and the row shows
  /// whichever one applies.
  String _timestampLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;

    if (article.isPublished && article.publishedAt != null) {
      return l10n.publishedOn(
        DateFormat.MMMd(locale).format(article.publishedAt!),
      );
    }

    final savedAt = article.updatedAt ?? article.createdAt;

    return savedAt == null
        ? l10n.notSavedYet
        : l10n.savedOn(DateFormat.MMMd(locale).format(savedAt));
  }

  static String _compactCount(int value) {
    if (value < 1000) {
      return '$value';
    }

    final thousands = value / 1000;

    return '${thousands.toStringAsFixed(thousands < 10 ? 1 : 0)}K';
  }
}
