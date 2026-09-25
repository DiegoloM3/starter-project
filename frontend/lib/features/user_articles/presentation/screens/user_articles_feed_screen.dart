import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/feed/user_articles_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/feed/user_articles_feed_state.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import '../widgets/create_article_tile.dart';
import '../widgets/user_article_tile.dart';

class UserArticlesFeedScreen extends StatefulWidget {
  const UserArticlesFeedScreen({super.key});

  @override
  State<UserArticlesFeedScreen> createState() =>
      _UserArticlesFeedScreenState();
}

class _UserArticlesFeedScreenState extends State<UserArticlesFeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    unawaited(context.read<UserArticlesFeedCubit>().loadArticles());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Both tabs read from the one paginated, author-scoped query (see
  // UserArticlesFeedCubit) and just filter it client-side by isDraft, so
  // scrolling near the bottom of either tab asks for the same next page.
  // 200px before the end, so the next page is usually ready by the time
  // the reader actually reaches the bottom of the list.
  bool _handleScrollNotification(ScrollNotification notification) {
    final nearBottom = notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200;
    if (nearBottom) {
      unawaited(context.read<UserArticlesFeedCubit>().loadMore());
    }
    return false;
  }

  Future<void> _openDetail(BuildContext context, String articleId) async {
    await Navigator.pushNamed(context, '/UserArticleDetail',
        arguments: articleId);
    if (context.mounted) {
      unawaited(context.read<UserArticlesFeedCubit>().loadArticles());
    }
  }

  // A draft has no public detail page -- it's unfinished, so tapping it
  // goes straight back into editing it, same as tapping "Edit" on a
  // published one does from its detail screen.
  Future<void> _openDraft(BuildContext context, UserArticleEntity draft) async {
    await Navigator.pushNamed(context, '/UserArticleForm', arguments: draft);
    if (context.mounted) {
      unawaited(context.read<UserArticlesFeedCubit>().loadArticles());
    }
  }

  Future<void> _openCreateForm(BuildContext context) async {
    await Navigator.pushNamed(context, '/UserArticleForm');
    if (context.mounted) {
      unawaited(context.read<UserArticlesFeedCubit>().loadArticles());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      // Switching accounts or signing out changes whose articles these are.
      listenWhen: (previous, current) =>
          previous.account != null &&
          previous.account?.id != current.account?.id,
      listener: (context, _) =>
          unawaited(context.read<UserArticlesFeedCubit>().loadArticles()),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myArticlesTitle),
        bottom: _StatusTabs(controller: _tabController),
      ),
      body: BlocBuilder<UserArticlesFeedCubit, UserArticlesFeedState>(
        builder: (context, state) {
          if (state is UserArticlesFeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserArticlesFeedError) {
            return Center(child: Text(context.l10n.genericError));
          }
          if (state is UserArticlesFeedLoaded) {
            // Nothing written at all yet -- the "+" tab creates articles
            // regardless of which of these two tabs is open, so this
            // invitation stands in for both rather than picking one.
            if (state.articles.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<UserArticlesFeedCubit>().loadArticles(),
                child: _buildEmptyState(context),
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTab(context, state, isDraft: false),
                _buildTab(context, state, isDraft: true),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      // Scrollable even with one row, so pull-to-refresh still works.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [CreateArticleTile(onTap: () => _openCreateForm(context))],
    );
  }

  Widget _buildTab(
    BuildContext context,
    UserArticlesFeedLoaded state, {
    required bool isDraft,
  }) {
    final articles =
        state.articles.where((a) => a.isDraft == isDraft).toList();
    return RefreshIndicator(
      onRefresh: () => context.read<UserArticlesFeedCubit>().loadArticles(),
      child: articles.isEmpty
          ? _buildEmptyTab(context, isDraft: isDraft)
          : _buildArticleList(context, articles, state.isLoadingMore,
              isDraft: isDraft),
    );
  }

  Widget _buildEmptyTab(BuildContext context, {required bool isDraft}) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: [
        Icon(
          isDraft ? Icons.edit_note_outlined : Icons.public_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          isDraft ? context.l10n.draftsEmptyTitle : context.l10n.publishedEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          isDraft
              ? context.l10n.draftsEmptyDetail
              : context.l10n.publishedEmptyDetail,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    List<UserArticleEntity> articles,
    bool isLoadingMore, {
    required bool isDraft,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6, bottom: 110),
        itemCount: articles.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final article = articles[index];
          return UserArticleTile(
            article: article,
            index: index,
            onTap: () => isDraft
                ? _openDraft(context, article)
                : _openDetail(context, article.id),
          );
        },
      ),
    );
  }
}

/// Published / Drafts as a pill-shaped segmented bar, each with how many
/// articles it holds.
class _StatusTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const _StatusTabs({required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  // Counted from what's loaded so far; "+" while more pages exist, so the
  // number never claims to be the whole total when it isn't.
  static String? _countLabel(
    UserArticlesFeedState state, {
    required bool isDraft,
  }) {
    if (state is! UserArticlesFeedLoaded) return null;
    final count = state.articles.where((a) => a.isDraft == isDraft).length;
    return state.hasMore ? '$count+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<UserArticlesFeedCubit, UserArticlesFeedState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: TabBar(
            controller: controller,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            splashBorderRadius: BorderRadius.circular(10),
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: [
              _StatusTab(
                label: context.l10n.publishedTab,
                count: _countLabel(state, isDraft: false),
              ),
              _StatusTab(
                label: context.l10n.draftsTab,
                count: _countLabel(state, isDraft: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final String? count;

  const _StatusTab({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
