import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/article_source.dart';
import 'package:news_app_clean_architecture/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/routes/community_routes.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/community_article_entity.dart';
import '../bloc/detail/community_article_detail_bloc.dart';
import '../bloc/detail/community_article_detail_event.dart';
import '../bloc/detail/community_article_detail_state.dart';

/// Community article detail screen.
/// AppBar has edit (pencil) and delete (trash) actions.
/// Shows COMMUNITY badge, title, author row, image+caption, bold lede,
/// body text, blockquote, and category tags at the bottom.
class CommunityArticleDetailScreen extends HookWidget {
  final String? title;

  const CommunityArticleDetailScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CommunityArticleDetailBloc,
      CommunityArticleDetailState
    >(
      listener: (context, state) {
        switch (state.status) {
          case CommunityArticleDetailStatus.deleted:
            context.showSnackBar('Article deleted.');
            context.goToCommunity();
          case CommunityArticleDetailStatus.failure:
            context.showSnackBar(
              state.failure?.message ?? 'Something went wrong.',
              isError: true,
            );
          case _:
            break;
        }
      },
      builder: (context, state) {
        if (state.status == CommunityArticleDetailStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final article = state.article;
        final articleContent = _plainTextFromContent(article?.content);
        final authState = context.watch<AuthBloc>().state;
        final bookmarkState = context.watch<BookmarkBloc>().state;
        final isOwner =
            article != null &&
            authState is AuthAuthenticated &&
            article.authorId == authState.user.uid;
        final isBookmarked =
            article != null &&
            bookmarkState is BookmarksDone &&
            bookmarkState.bookmarks.any(
              (bookmark) =>
                  bookmark.source == ArticleSource.community &&
                  bookmark.sourceId == article.id,
            );
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                foregroundColor: context.colorScheme.onSurface,
                elevation: 0,
                leading: const BackButton(),
                title: Text(
                  'Symmetry NEWS',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (article != null)
                    IconButton(
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border_outlined,
                        size: 20,
                        color: isBookmarked ? AppColors.primary : null,
                      ),
                      onPressed: () => _toggleBookmark(
                        context,
                        article,
                        isBookmarked: isBookmarked,
                      ),
                    ),
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => context.go('/editor', extra: article),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showDeleteSheet(context, article),
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryBadge(
                        (article?.category ?? 'COMMUNITY').toUpperCase(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        article?.title ??
                            title ??
                            'Local Park Renovation Initiative Breaks Ground This Weekend',
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
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
                                article?.authorName ?? 'Elena Rostova',
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                _publishedAtLabel(article),
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
                      _buildImage(context, article),
                      const SizedBox(height: 6),
                      Text(
                        'Photo by Community Lens',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        article?.description ??
                            'After years of planning and fundraising, the long-awaited renovation of Centennial Park is officially underway, promising new green spaces and recreational facilities for the neighborhood.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        articleContent ??
                            'The initiative, spearheaded by a coalition of local residents and small business owners, aims to transform the aging park into a modern hub for community activities. The project will replace outdated playground equipment, install native plant gardens, and create accessible pathways connecting the main plaza to the surrounding streets.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          '"We want a park that reflects the vibrancy of the people who live here today."',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        article == null
                            ? 'Volunteers are expected to gather this Saturday at 8:00 AM to begin the initial phase of clearing debris and preparing the soil. The city council recently approved a matching grant that will cover the cost of the new playground structures, which are scheduled for delivery next month.'
                            : articleContent ?? '',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CategoryBadge(
                            (article?.category ?? 'LOCAL NEWS').toUpperCase(),
                            filled: false,
                          ),
                          const CategoryBadge('URBAN RENEWAL', filled: false),
                          const CategoryBadge('VOLUNTEERING', filled: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, CommunityArticleEntity? article) {
    if (article?.imageUrl != null && article!.imageUrl!.isNotEmpty) {
      return Image.network(
        article.imageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 220,
      color: AppColors.surfaceContainer,
      child: const Center(
        child: Icon(Icons.image, size: 48, color: AppColors.outline),
      ),
    );
  }

  String _publishedAtLabel(CommunityArticleEntity? article) {
    if (article == null) return 'Oct 24, 2023 • 4 min read';
    final publishedAt = article.publishedAt;
    return '${_monthName(publishedAt.month)} ${publishedAt.day}, ${publishedAt.year} • 4 min read';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _showDeleteSheet(BuildContext context, CommunityArticleEntity? article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteConfirmationSheet(
        onDelete: () {
          Navigator.pop(context);
          if (article != null) {
            context.read<CommunityArticleDetailBloc>().add(
              const CommunityArticleDeleteRequested(),
            );
          }
        },
      ),
    );
  }

  void _toggleBookmark(
    BuildContext context,
    CommunityArticleEntity article, {
    required bool isBookmarked,
  }) {
    final bookmarkBloc = context.read<BookmarkBloc>();
    if (isBookmarked) {
      bookmarkBloc.add(
        RemoveBookmarkEvent(article.id, ArticleSource.community),
      );
      return;
    }

    bookmarkBloc.add(
      AddBookmarkEvent(
        BookmarkEntity(
          sourceId: article.id,
          source: ArticleSource.community,
          title: article.title,
          description: article.description,
          imageUrl: article.imageUrl,
          author: article.authorName,
          publishedAt: article.publishedAt.toIso8601String(),
          content: article.content,
        ),
      ),
    );
  }
}

String? _plainTextFromContent(String? content) {
  if (content == null || content.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(content);
    final List<dynamic>? operations = switch (decoded) {
      final List<dynamic> ops => ops,
      final Map<String, dynamic> map => map['ops'] as List<dynamic>?,
      _ => null,
    };

    if (operations == null) {
      return content;
    }

    final buffer = StringBuffer();
    for (final operation in operations) {
      if (operation case {'insert': final String text}) {
        buffer.write(text);
      }
    }

    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    return content;
  }
}
