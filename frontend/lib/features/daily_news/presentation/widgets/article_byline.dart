import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'journalist_badge.dart';
import 'publication_date_text.dart';

/// Line under the title of an article: who wrote it, when it is a
/// journalist of the app, and how long ago it was published.
class ArticleByline extends StatelessWidget {
  final ArticleEntity article;
  final IconData dateIcon;

  const ArticleByline({Key? key, required this.article, required this.dateIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final publicationDate = article.publicationDate;
    return Row(
      children: [
        if (article.isWrittenByJournalist) ...[
          const JournalistBadge(),
          const SizedBox(width: 8),
        ],
        if (publicationDate != null) ...[
          Icon(dateIcon, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: PublicationDateText(publicationDate: publicationDate, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}
