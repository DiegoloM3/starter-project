import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../extensions/build_context_extensions.dart';
import '../previews/app_preview.dart';
import 'category_badge.dart';

/// Full-width hero card with an image, category badge overlay, large serif title,
/// optional description and byline. Used on Home News tab and Saved Articles.
/// Responsive layout adapts to different screen sizes.
class HeroArticleCard extends StatelessWidget {
  const HeroArticleCard({
    required this.title,
    super.key,
    this.imageUrl,
    this.category,
    this.description,
    this.author,
    this.publishedAt,
    this.onTap,
  });

  final String title;
  final String? imageUrl;
  final String? category;
  final String? description;
  final String? author;
  final String? publishedAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null) ...[
                        CategoryBadge(category!),
                        const SizedBox(height: 8),
                      ],
                      Text(title, style: context.textTheme.titleLarge),
                      ...?_descriptionChildren(context),
                      ...?_metadataChildren(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget>? _descriptionChildren(BuildContext context) {
    final description = this.description;
    if (description == null) return null;

    return [
      const SizedBox(height: 6),
      Text(
        description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  List<Widget>? _metadataChildren(BuildContext context) {
    final metadata = [?(author == null ? null : 'By $author'), ?publishedAt];
    if (metadata.isEmpty) return null;

    return [
      const SizedBox(height: 8),
      Text(metadata.join(' \u2022 '), style: context.textTheme.labelSmall),
    ];
  }

  Widget _buildImage(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        color: context.colorScheme.surfaceContainer,
        child: Icon(
          Ionicons.image_outline,
          size: 48,
          color: context.colorScheme.outline,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(
        width: double.infinity,
        height: 220,
        color: context.colorScheme.surfaceContainer,
      ),
      errorWidget: (_, _, _) => Container(
        width: double.infinity,
        height: 220,
        color: context.colorScheme.surfaceContainer,
        child: Icon(
          Ionicons.image_outline,
          size: 48,
          color: context.colorScheme.outline,
        ),
      ),
    );
  }
}

/// Preview of hero article card.
@AppPreview(name: 'Hero Article Card')
Widget previewHeroArticleCard() {
  return const Material(
    child: HeroArticleCard(
      title: 'Flutter Framework Latest Updates and Features',
      imageUrl:
          'https://images.unsplash.com/photo-1456952452733-86d440d0c4f6?w=600',
      category: 'Technology',
      description:
          'Discover the newest improvements and capabilities available in the latest Flutter release.',
      author: 'Flutter Team',
      publishedAt: 'Feb 11, 2026',
    ),
  );
}
