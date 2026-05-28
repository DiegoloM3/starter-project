import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/article.dart';

/// Full-width lead story card matching the Ink & Paper "FeatureCard" design.
///
/// Hero image (185px) with gradient overlay + optional category badge,
/// followed by serif title, sans snippet, and author meta row.
class FeatureCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;

  const FeatureCard({
    Key? key,
    required this.article,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroImage(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final url = article.thumbnailUrl;
    return SizedBox(
      height: 185,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or placeholder gradient
          if (url != null && url.isNotEmpty)
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.ink.withValues(alpha: 0.12),
              ),
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.6, -0.8),
                    end: Alignment(0.6, 0.8),
                    colors: [Color(0xFF1E3A5F), Color(0xFF2D6A9F)],
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.6, -0.8),
                  end: Alignment(0.6, 0.8),
                  colors: [Color(0xFF1E3A5F), Color(0xFF2D6A9F)],
                ),
              ),
            ),
          // Bottom gradient overlay for text readability
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x8C000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article.title ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.serif(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.t1,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 6),
          // Snippet / description
          if (article.description != null &&
              article.description!.isNotEmpty)
            Text(
              article.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(
                fontSize: 12.5,
                color: AppColors.t2,
                height: 1.55,
              ),
            ),
          const SizedBox(height: 10),
          // Author meta
          _buildAuthorMeta(),
        ],
      ),
    );
  }

  Widget _buildAuthorMeta() {
    final authorName = article.authorName ?? '';
    final initials = authorName.isNotEmpty
        ? authorName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Row(
      children: [
        // Avatar circle
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: AppTypography.sans(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 7),
        if (authorName.isNotEmpty) ...[
          Text(
            authorName,
            style: AppTypography.sans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.t2,
            ),
          ),
          _dot(),
        ],
        if (article.publishedAt != null)
          Text(
            article.publishedAt!,
            style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
          ),
        if (article.readingTimeMinutes != null) ...[
          _dot(),
          Text(
            '${article.readingTimeMinutes} min read',
            style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
          ),
        ],
      ],
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
      ),
    );
  }
}
