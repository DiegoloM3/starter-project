import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/reader_scaffold.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_timestamp.dart';

/// Reading one world news article.
///
/// The same frame as the community reader, with two differences that come
/// from the data rather than from taste: this one can be saved for later, and
/// it has no author page to send the reader on to.
class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final article = this.article;

    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleUnavailable),
        ),
      );
    }

    final theme = Theme.of(context);

    return ReaderScaffold(
      coverUrl: article.urlToImage,
      bottomAction: BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: (context, state) {
          // Read from the shared saved list rather than from a flag this
          // screen keeps: an article saved on a previous visit has to come
          // back as saved, or it can be saved twice.
          final saved = state.articles?.any(article.isSameArticleAs) ?? false;

          return _SaveButton(
            saved: saved,
            onPressed: () =>
                saved ? _remove(context, article) : _save(context, article),
          );
        },
      ),
      children: [
        Text(
          article.title ?? '',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SourceRow(article: article),
        const SizedBox(height: AppSpacing.xxl),
        if ((article.description ?? '').isNotEmpty) ...[
          Text(
            article.description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(article.content ?? '', style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xxl),
        _SourceNotice(url: article.url ?? ''),
      ],
    );
  }

  void _save(BuildContext context, ArticleEntity article) {
    context.read<LocalArticleBloc>().add(SaveArticle(article));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).savedConfirmation),
          duration: kUndoDuration,
        ),
      );
  }

  void _remove(BuildContext context, ArticleEntity article) {
    context.read<LocalArticleBloc>().add(RemoveArticle(article));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).removedFromSaved),
          duration: kUndoDuration,
        ),
      );
  }
}

/// Says that the story stops here, and where the rest of it is.
///
/// The News API's free tier sends roughly the first 200 characters of an
/// article and marks the cut with `[+2431 chars]`. That marker is stripped on
/// the way in, which stops it being read as part of the story but leaves the
/// text ending mid-sentence. Rather than let that look like a bug in the app,
/// the reader is told what happened and given the address of the original —
/// selectable, so it can be copied into a browser.
class _SourceNotice extends StatelessWidget {
  final String url;

  const _SourceNotice({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.newsPreviewNotice, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.openAtSource,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            url,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final ArticleEntity article;

  const _SourceRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = article.author ?? '';

    return Row(
      children: [
        if (author.isNotEmpty) ...[
          AuthorAvatar(name: author),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (author.isNotEmpty)
                Text(
                  author,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              ArticleTimestamp(
                rawDate: article.publishedAt,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Saves the article, or takes it back out.
///
/// It stays enabled once saved rather than going dead: the reader who saved
/// something by mistake needs a way back, and this is the control they
/// already have their thumb on.
class _SaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onPressed;

  const _SaveButton({required this.saved, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 20),
      label: Text(
        saved
            ? AppLocalizations.of(context).saved
            : AppLocalizations.of(context).save,
      ),
      style: saved
          ? FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
            )
          : null,
    );
  }
}
