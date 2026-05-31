import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../routes/community_routes.dart';
import '../bloc/articles/community_articles_bloc.dart';
import '../bloc/articles/community_articles_event.dart';
import '../bloc/articles/community_articles_state.dart';

/// Community tab list of community-submitted articles.
class HomeCommunityTab extends HookWidget {
  const HomeCommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        if (scrollController.hasClients &&
            scrollController.position.pixels >
                scrollController.position.maxScrollExtent * 0.8) {
          context.read<CommunityArticlesBloc>().add(
            const CommunityArticlesNextPageRequested(),
          );
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, scrollController),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/editor'),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: context.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScrollController scrollController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: context.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'COMMUNITY SUBMISSIONS',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<CommunityArticlesBloc, CommunityArticlesState>(
            builder: (context, state) {
              switch (state.status) {
                case CommunityArticlesStatus.initial:
                case CommunityArticlesStatus.loading:
                  return const Center(child: CupertinoActivityIndicator());
                case CommunityArticlesStatus.failure:
                  return ErrorDisplay(
                    message: state.failure?.message ?? 'Something went wrong.',
                    onRetry: () => context.read<CommunityArticlesBloc>().add(
                      const CommunityArticlesRequested(),
                    ),
                    icon: Icons.wifi_off_outlined,
                  );
                case CommunityArticlesStatus.success:
                  return _buildArticleList(context, state, scrollController);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    CommunityArticlesState state,
    ScrollController scrollController,
  ) {
    if (state.articles.isEmpty) {
      return Center(
        child: Text(
          'No community articles yet.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CommunityArticlesBloc>().add(
          const CommunityArticlesRefreshRequested(),
        );
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.articles.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          final article = state.articles[index];
          return CommunityArticleTile(
            key: ValueKey(article.id),
            authorName: article.authorName,
            avatarInitials: _initialsFor(article.authorName),
            category: (article.category ?? 'COMMUNITY').toUpperCase(),
            isFeatured: index == 0,
            title: article.title,
            excerpt: article.description ?? article.content,
            timeAgo: _formatTimeAgo(article.publishedAt),
            commentCount: 0,
            onTap: () => context.goToCommunityDetail(article),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.go('/profile'),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: context.colorScheme.surfaceContainer,
            child: Icon(
              Icons.person_outline,
              color: context.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        'Symmetry NEWS',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/search'),
          icon: Icon(Icons.search, color: context.colorScheme.onSurface),
        ),
      ],
    );
  }

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatTimeAgo(DateTime publishedAt) {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
