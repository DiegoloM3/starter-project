import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_toast.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_actions.dart';
import '../../widgets/news_formatting.dart';

/// A NewsAPI story laid out like an article page: kicker, headline, the
/// summary as its subtitle, byline, photo, the text NewsAPI shares, and a
/// way to the full story on the publisher's site.
class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailsView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = article.description ?? '';
    return Scaffold(
      // Save lives up here, not in a FAB: a FAB sat on top of the end of
      // short articles. Bookmark state is shared app-wide (see main.dart).
      appBar: AppBar(
        actions: [
          ShareButton(article: article),
          BookmarkButton(article: article),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_kicker(context), style: theme.textTheme.labelMedium),
            const SizedBox(height: 10),
            Text(
              article.title ?? '',
              style: theme.textTheme.displayLarge
                  ?.copyWith(fontSize: 30, height: 1.2),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 16),
            _buildByline(context),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AppImage(url: article.urlToImage),
              ),
            ),
            const SizedBox(height: 20),
            if (_bodyText.isNotEmpty) ...[
              Text(_bodyText, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
            ],
            _buildReadFullArticle(context),
          ],
        ),
      ),
    );
  }

  String _kicker(BuildContext context) {
    final source = (article.sourceName ?? '').toUpperCase();
    final ago = timeAgo(article.publishedAt, context.l10n);
    return [source, ago].where((part) => part.isNotEmpty).join('  ·  ');
  }

  // NewsAPI's excerpt often just repeats the summary shown right above it.
  String get _bodyText {
    final content = article.content ?? '';
    final description = article.description ?? '';
    final opening =
        description.length < 40 ? description : description.substring(0, 40);
    final repeatsSummary = opening.isNotEmpty && content.startsWith(opening);
    return repeatsSummary ? '' : content;
  }

  Widget _buildByline(BuildContext context) {
    final theme = Theme.of(context);
    final author = article.author ?? '';
    final published = DateTime.tryParse(article.publishedAt ?? '');
    final date = published == null
        ? ''
        : DateFormat.yMMMd().add_jm().format(published.toLocal());
    return Text.rich(
      TextSpan(
        children: [
          if (author.isNotEmpty)
            TextSpan(
              text: context.l10n.byAuthor(author),
              style: theme.textTheme.titleMedium,
            ),
          if (author.isNotEmpty && date.isNotEmpty)
            const TextSpan(text: '  ·  '),
          TextSpan(text: date),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildReadFullArticle(BuildContext context) {
    final theme = Theme.of(context);
    final source = article.sourceName ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (source.isNotEmpty) ...[
          Text(context.l10n.fullStoryOn(source),
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          onPressed: () => _openFullArticle(context),
          icon: const Icon(Icons.open_in_new),
          label: Text(context.l10n.readFullArticle),
        ),
      ],
    );
  }

  Future<void> _openFullArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url ?? '');
    final opened = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      AppToast.show(context,
          message: context.l10n.couldNotOpenArticle, type: AppToastType.error);
    }
  }
}
