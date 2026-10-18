import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/article.dart';
import 'topic_names.dart';

/// Topics of an article in small capitals, e.g. "TECNOLOGÍA · CULTURA".
class ArticleTopicsText extends StatelessWidget {
  final ArticleEntity article;

  const ArticleTopicsText({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Text(
      article.topics.map((topic) => topic.displayName.toUpperCase()).join(' · '),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
    );
  }
}

/// Author, date and reading time, e.g. "Jane Doe · 16 oct 2026 · 2 min".
/// With [onAuthorTap], the author name is bold and opens their profile.
class ArticleMetaText extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onAuthorTap;

  const ArticleMetaText({super.key, required this.article, this.onAuthorTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final details = '${DateFormat.yMMMd().format(article.publishedAt)} · ${article.readingTimeInMinutes} min';
    if (onAuthorTap == null) return Text('${article.authorName} · $details', style: style);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: onAuthorTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              article.authorName,
              style: style?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Text(' · $details', style: style),
      ],
    );
  }
}
