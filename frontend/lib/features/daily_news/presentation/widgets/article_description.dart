import 'package:flutter/material.dart';

import '../utils/sanitize_article_content.dart';

class ArticleDescription extends StatelessWidget {
  final String description;
  final String content;

  const ArticleDescription({
    Key? key,
    required this.description,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sanitized = sanitizeArticleContent(content);
    final hasDescription = description.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDescription)
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          if (hasDescription && (sanitized != null)) const SizedBox(height: 16),
          if (sanitized != null)
            Text(
              sanitized,
              style: const TextStyle(fontSize: 16),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: hasDescription ? 16 : 0),
              child: const Text(
                'Full article available at the source.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF757575),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
