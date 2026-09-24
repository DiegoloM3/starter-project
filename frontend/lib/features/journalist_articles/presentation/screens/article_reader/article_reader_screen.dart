import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/article_markdown.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/reader_scaffold.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../bloc/article_feed/article_feed_cubit.dart';
import '../../bloc/article_feed/article_feed_state.dart';
import '../../bloc/article_reader/article_reader_cubit.dart';
import '../../bloc/article_reader/article_reader_state.dart';

/// Reading one community article, and finding the rest of what its author
/// has written.
class ArticleReaderScreen extends StatelessWidget {
  const ArticleReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleReaderCubit, ArticleReaderState>(
      builder: (context, state) {
        final article = state.article;

        return ReaderScaffold(
          coverUrl: article.thumbnailUrl,
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _AuthorRow(article: article),
            const SizedBox(height: AppSpacing.xxl),
            _ArticleBody(article: article),
            const SizedBox(height: AppSpacing.xxl),
            const _MoreFromAuthor(),
          ],
        );
      },
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final JournalistArticleEntity article;

  const _AuthorRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publishedAt = article.publishedAt;

    return Row(
      children: [
        AuthorAvatar(name: article.author),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.author,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (publishedAt != null) ...[
                    Text(
                      DateFormat.MMMd(AppLocalizations.of(context).localeName)
                          .format(publishedAt),
                      style: theme.textTheme.labelSmall,
                    ),
                    Text('  •  ', style: theme.textTheme.labelSmall),
                  ],
                  Icon(
                    Icons.visibility_outlined,
                    size: 13,
                    color: theme.textTheme.labelSmall?.color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppLocalizations.of(context)
                        .viewsCount('${article.viewCount}'),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArticleBody extends StatelessWidget {
  final JournalistArticleEntity article;

  const _ArticleBody({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.description.isNotEmpty) ...[
          Text(
            article.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // The body is Markdown. Articles written before that was true are
        // plain text, which Markdown renders unchanged, so nothing stored
        // needs migrating.
        ArticleMarkdown(article.content),
      ],
    );
  }
}

/// The author's other published articles.
///
/// It disappears entirely when there are none, rather than leaving a heading
/// over an empty strip.
class _MoreFromAuthor extends StatelessWidget {
  const _MoreFromAuthor();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleFeedCubit, ArticleFeedState>(
      builder: (context, state) {
        if (state.articles.isEmpty) {
          return const SizedBox.shrink();
        }

        final author = context.read<ArticleReaderCubit>().state.article.author;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context).moreFrom(
                _firstNameOf(AppLocalizations.of(context), author),
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.articles.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) => _MoreFromCard(
                  article: state.articles[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// "More from Marcus" reads like a person; "More from Marcus Aurelius"
  /// reads like a byline.
  static String _firstNameOf(AppLocalizations l10n, String author) {
    final trimmed = author.trim();

    return trimmed.isEmpty
        ? l10n.thisAuthor
        : trimmed.split(RegExp(r'\s+')).first;
  }
}

class _MoreFromCard extends StatelessWidget {
  final JournalistArticleEntity article;

  const _MoreFromCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            // Replaces the article being read instead of stacking another
            // reader on top, so hopping between an author's pieces does not
            // build a back stack nobody wants to unwind.
            onTap: () => Navigator.pushReplacementNamed(
              context,
              '/ArticleReader',
              arguments: article,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: article.thumbnailUrl.isEmpty
                          ? ColoredBox(
                              color: Theme.of(context).dividerColor,
                            )
                          : CachedNetworkImage(
                              imageUrl: article.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      article.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                              ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
