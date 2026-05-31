import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../extensions/build_context_extensions.dart';
import '../previews/app_preview.dart';
import 'category_badge.dart';

/// Community article list tile with avatar, author name, category badge,
/// serif title, excerpt, timestamp and comment count.
class CommunityArticleTile extends StatelessWidget {
  const CommunityArticleTile({
    required this.authorName,
    required this.title,
    required this.excerpt,
    required this.timeAgo,
    required this.commentCount,
    super.key,
    this.avatarUrl,
    this.avatarInitials,
    this.category = 'COMMUNITY',
    this.isFeatured = false,
    this.onTap,
  });

  final String authorName;
  final String title;
  final String excerpt;
  final String timeAgo;
  final int commentCount;
  final String? avatarUrl;
  final String? avatarInitials;
  final String category;
  final bool isFeatured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row + category badge
            Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(authorName, style: context.textTheme.titleSmall),
                ),
                CategoryBadge(category, filled: isFeatured),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(title, style: context.textTheme.titleLarge),
            const SizedBox(height: 6),
            // Excerpt
            Text(
              excerpt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            // Footer: time + comments
            Row(
              children: [
                Text(timeAgo, style: context.textTheme.labelSmall),
                const Spacer(),
                Icon(
                  Ionicons.chatbox_ellipses_outline,
                  size: 14,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text('$commentCount', style: context.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: context.colorScheme.surfaceContainer,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: context.colorScheme.onSurfaceVariant,

      child: Text(
        avatarInitials ?? authorName.substring(0, 2).toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}

/// Preview of community article tile.
@AppPreview(name: 'Community Article Tile')
Widget previewCommunityArticleTile() {
  return const Material(
    child: CommunityArticleTile(
      authorName: 'Jane Smith',
      title: 'Great Tips for Flutter Development',
      excerpt:
          'In this article, I share some valuable insights I learned while building production apps...',
      timeAgo: '2 hours ago',
      commentCount: 24,
      avatarInitials: 'JS',
    ),
  );
}

/// Preview of featured community article tile.
@AppPreview(name: 'Community Article Tile Featured')
Widget previewCommunityArticleTileFeatured() {
  return const Material(
    child: CommunityArticleTile(
      authorName: 'John Doe',
      title: 'Featured Community Story',
      excerpt:
          'This article was selected as a featured community contribution...',
      timeAgo: '1 day ago',
      commentCount: 156,
      isFeatured: true,
      avatarInitials: 'JD',
    ),
  );
}
