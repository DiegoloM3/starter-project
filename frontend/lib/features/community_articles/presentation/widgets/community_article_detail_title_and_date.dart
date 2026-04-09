import 'package:flutter/material.dart';

import '../../../../core/utils/format_published_at.dart';

class CommunityArticleDetailTitleAndDate extends StatelessWidget {
  final String title;
  final String? publishedAt;

  const CommunityArticleDetailTitleAndDate({
    Key? key,
    required this.title,
    required this.publishedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (publishedAt != null && publishedAt!.isNotEmpty)
          Text(
            formatPublishedAt(publishedAt),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
      ],
    );
  }
}
