import 'package:flutter/material.dart';

import 'community_article_detail_title_and_date.dart';

class CommunityArticleDetailBody extends StatelessWidget {
  final String title;
  final String? publishedAt;
  final String description;
  final String content;

  const CommunityArticleDetailBody({
    Key? key,
    required this.title,
    required this.publishedAt,
    required this.description,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityArticleDetailTitleAndDate(
            title: title,
            publishedAt: publishedAt,
          ),
          const SizedBox(height: 16),
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
