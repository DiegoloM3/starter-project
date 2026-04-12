import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

class ArticleUploadTile extends StatelessWidget {
  final ArticleUploadEntity article;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ArticleUploadTile({
    super.key,
    required this.article,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(article.publishedAt);
    final semanticLabel =
        'Article: ${article.title}. By ${article.author}. Published $formattedDate';

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      container: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Hero(
                    tag: 'article-thumb-${article.id}',
                    child: _Thumbnail(url: article.thumbnailURL),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExcludeSemantics(child: _Info(article: article)),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete article',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    const double size = 88;
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: _imageFor(url, placeholder),
      ),
    );
  }

  Widget _imageFor(String source, Color placeholder) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.cover,
        placeholder: (_, __) => ColoredBox(color: placeholder),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    final file = File(source);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: placeholder,
      child: const Icon(Icons.image_not_supported),
    );
  }
}

class _Info extends StatelessWidget {
  final ArticleUploadEntity article;
  const _Info({required this.article});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.65);
    final formattedDate = DateFormat.yMMMd().format(article.publishedAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          article.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: muted),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.person_outline, size: 14, color: muted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                article.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
            Icon(Icons.schedule, size: 14, color: muted),
            const SizedBox(width: 4),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ],
    );
  }
}
