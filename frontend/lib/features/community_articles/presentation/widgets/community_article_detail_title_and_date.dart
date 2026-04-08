import 'package:flutter/material.dart';

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
        if (publishedAt != null)
          Text(
            publishedAt!.substring(0, 10),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
      ],
    );
  }
}
