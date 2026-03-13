import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user_article.dart';

/// Compact article card for article lists (Top Stories style)
class ArticleListCard extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback? onTap;

  const ArticleListCard({
    Key? key,
    required this.article,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildContent()),
            const SizedBox(width: 16),
            _buildImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final timeAgo = _formatTimeAgo(
        article.publishedAt ?? article.createdAt ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        if ((article.categories ?? []).isNotEmpty)
          Text(
            (article.categories ?? []).first.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B5BDB),
              letterSpacing: 0.5,
            ),
          ),
        const SizedBox(height: 6),
        // Title
        Text(
          article.title ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Author and time
        Row(
          children: [
            Text(
              article.authorName ?? 'Unknown',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: article.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_outlined,
                  color: Colors.grey[400],
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: Colors.grey[400],
                size: 32,
              ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
