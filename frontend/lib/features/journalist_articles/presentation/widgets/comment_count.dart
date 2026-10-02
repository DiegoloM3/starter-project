import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

/// Speech bubble with the number of comments of an article.
class CommentCount extends StatelessWidget {
  final int count;

  const CommentCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = context.palette.textSecondary;
    return Semantics(
      label: count == 1 ? '1 comment' : '$count comments',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.chatbubbleOutline, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
