import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/article.dart';

/// Premium news card with two variants:
/// - **Featured** (`isFeatured: true`): large full-width image with gradient
///   overlay and title on top. Used for the first article in the list.
/// - **Regular** (`isFeatured: false`, default): compact horizontal card with
///   square thumbnail, title, description, and metadata.
class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final bool isFeatured;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    super.key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = article?.title ?? 'Untitled article';
    final author = article?.author ?? 'unknown author';
    return Semantics(
      label: 'Article: $title. By $author',
      button: onArticlePressed != null,
      container: true,
      child: isFeatured
          ? _FeaturedCard(article: article!, onTap: _onTap)
          : _RegularCard(
              article: article!,
              onTap: _onTap,
              isRemovable: isRemovable ?? false,
              onRemove: _onRemove,
            ),
    );
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }
}

// ─── FEATURED CARD (first article) ──────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const _FeaturedCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image.
                ExcludeSemantics(
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        ColoredBox(color: colors.surfaceContainerHighest),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
                // Gradient overlay.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                // Content.
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Source badge.
                      if (article.author != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.author!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      // Title.
                      Text(
                        article.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Date.
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(article.publishedAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── REGULAR CARD ───────────────────────────────────────────────────────────

class _RegularCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;
  final bool isRemovable;
  final VoidCallback onRemove;

  const _RegularCard({
    required this.article,
    required this.onTap,
    required this.isRemovable,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1.5,
          child: SizedBox(
            height: 130,
            child: Row(
              children: [
                // Thumbnail.
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: SizedBox(
                      width: 110,
                      height: 130,
                      child: CachedNetworkImage(
                        imageUrl: article.urlToImage ?? '',
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            ColoredBox(color: colors.surfaceContainerHighest),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text content.
                Expanded(
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              article.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: muted),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 13, color: muted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDate(article.publishedAt),
                                  style: TextStyle(fontSize: 11, color: muted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isRemovable)
                                IconButton(
                                  onPressed: onRemove,
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Remove from saved',
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DATE FORMATTER ─────────────────────────────────────────────────────────

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(dt);
  } catch (_) {
    return raw;
  }
}
