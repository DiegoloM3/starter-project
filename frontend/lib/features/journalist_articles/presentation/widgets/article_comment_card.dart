import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/user_avatar.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';

import 'package:news_app_clean_architecture/config/theme/publication_date_text.dart';

/// A comment with the avatar, name and date of its author.
class ArticleCommentCard extends StatelessWidget {
  static const double _avatarSize = 40;

  final ArticleCommentEntity comment;

  const ArticleCommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: palette.textPrimary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(initials: comment.authorInitials, size: _avatarSize, hasShadow: false),
          const SizedBox(width: 12),
          Expanded(child: _buildTexts(palette)),
        ],
      ),
    );
  }

  Widget _buildTexts(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(comment.author, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            Text(
              formatDateTime(comment.createdAt),
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(comment.content, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}
