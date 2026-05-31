import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/design_system/design_system.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';
import '../../../domain/entities/article.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            foregroundColor: context.colorScheme.onSurface,
            elevation: 0,
            leading: const BackButton(),
            actions: [
              BlocSelector<BookmarkBloc, BookmarkState, bool>(
                selector: (state) =>
                    state is BookmarksDone &&
                    state.bookmarks.any(
                      (b) =>
                          b.sourceId == (article?.url ?? '') &&
                          b.source == ArticleSource.api,
                    ),
                builder: (context, isBookmarked) => IconButton(
                  onPressed: () {
                    if (isBookmarked) {
                      context.read<BookmarkBloc>().add(
                        RemoveBookmarkEvent(
                          article?.url ?? '',
                          ArticleSource.api,
                        ),
                      );
                      context.showSnackBar('Article removed.');
                    } else {
                      context.read<BookmarkBloc>().add(
                        AddBookmarkEvent(
                          BookmarkEntity(
                            sourceId: article?.url ?? '',
                            source: ArticleSource.api,
                            title: article?.title,
                            description: article?.description,
                            imageUrl: article?.urlToImage,
                            url: article?.url,
                            author: article?.author,
                            publishedAt: article?.publishedAt,
                            content: article?.content,
                          ),
                        ),
                      );
                      context.showSnackBar('Article saved.');
                    }
                  },
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked
                        ? AppColors.primary
                        : context.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.share_outlined,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                if (article?.urlToImage != null &&
                    article!.urlToImage!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: article!.urlToImage!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      height: 240,
                      color: AppColors.surfaceContainer,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 240,
                      color: AppColors.surfaceContainer,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      const CategoryBadge('EXCLUSIVE REPORT'),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        article?.title ?? '',
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Author row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                context.colorScheme.surfaceContainer,
                            child: Icon(
                              Icons.person_outline,
                              color: context.colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article?.author ?? 'Unknown Author',
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                _formatDate(article?.publishedAt),
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Body with drop-cap on first paragraph
                      if (article?.description != null) ...[
                        _DropCapParagraph(text: article!.description!),
                        const SizedBox(height: 16),
                      ],
                      if (article?.content != null) ...[
                        // Blockquote
                        const _Blockquote(
                          quote:
                              '"We are no longer simply building structures; we are engineering localized ecosystems."',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          article!.content!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _KeyDataPoints(),
                      ],
                      const SizedBox(height: 40),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String? publishedAt) {
    if (publishedAt == null) return '';
    try {
      final dt = DateTime.parse(publishedAt);
      return 'Oct ${dt.day}, ${dt.year}';
    } catch (_) {
      return publishedAt;
    }
  }
}

class _DropCapParagraph extends StatelessWidget {
  const _DropCapParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstChar = text[0];
    final rest = text.substring(1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstChar,
          style: context.textTheme.displayLarge?.copyWith(
            color: context.colorScheme.onSurface,
            height: 0.9,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            rest,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _Blockquote extends StatelessWidget {
  const _Blockquote({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Text(
        quote,
        style: context.textTheme.titleMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: context.colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}

class _KeyDataPoints extends StatelessWidget {
  const _KeyDataPoints();

  static const _points = [
    'Composite materials show a 40% reduction in overall weight.',
    'Generative structures increase wind sheer resistance by 22%.',
    'Urban construction timelines reduced by an average of 18 months.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY DATA POINTS',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ..._points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022 ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
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
