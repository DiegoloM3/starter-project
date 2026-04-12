import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

class ArticleUploadDetailScreen extends StatelessWidget {
  final ArticleUploadEntity article;

  const ArticleUploadDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.65);
    final formattedDate =
        DateFormat.yMMMMd().add_jm().format(article.publishedAt);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/EditArticle',
              arguments: article);
          if (context.mounted) Navigator.pop(context);
        },
        tooltip: 'Edit this article',
        child: const Icon(Icons.edit_outlined),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'article-thumb-${article.id}',
                child: Semantics(
                  label: 'Thumbnail image for the article "${article.title}"',
                  image: true,
                  child: _HeaderImage(url: article.thumbnailURL),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: muted),
                      const SizedBox(width: 4),
                      Text(article.author, style: TextStyle(color: muted)),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: muted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          formattedDate,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: muted),
                        ),
                      ),
                    ],
                  ),
                  if (article.sourceName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: muted),
                        const SizedBox(width: 4),
                        Text(article.sourceName!,
                            style: TextStyle(color: muted)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: colors.onSurface,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    article.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String url;
  const _HeaderImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final fallback = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => ColoredBox(
          color: fallback,
          child: const Icon(Icons.broken_image, size: 48),
        ),
      );
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: fallback,
      child: const Icon(Icons.image_not_supported, size: 48),
    );
  }
}
