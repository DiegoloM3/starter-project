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
class ArticleMetaText extends StatelessWidget {
  final ArticleEntity article;

  const ArticleMetaText({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd().format(article.publishedAt);
    return Text(
      '${article.authorName} · $date · ${article.readingTimeInMinutes} min',
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
