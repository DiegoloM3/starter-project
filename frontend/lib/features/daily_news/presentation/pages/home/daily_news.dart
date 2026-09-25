import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_toast.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'package:news_app_clean_architecture/shared/connectivity/domain/entities/connectivity_status.dart';
import 'package:news_app_clean_architecture/shared/connectivity/presentation/bloc/connectivity_cubit.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/category_bar.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/latest_ticker.dart';
import '../../widgets/news_masthead.dart';
import '../../widgets/shimmer.dart';
import '../../widgets/story_tiles.dart';

/// The front page: sections, the latest headline, featured photo stories
/// and the rest of the day's stories, loading more as you scroll.
class DailyNews extends StatefulWidget {
  /// Fires when the News tab is tapped while already open; scrolls to the
  /// top, the way tapping the current tab does in most apps.
  final Listenable? scrollToTop;

  const DailyNews({super.key, this.scrollToTop});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  static const _featuredCount = 5;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.scrollToTop?.addListener(_scrollToTop);
  }

  @override
  void dispose() {
    widget.scrollToTop?.removeListener(_scrollToTop);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _onScroll() {
    // Well before the end, so the next page is usually there in time.
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      context.read<RemoteArticlesBloc>().add(const LoadMoreArticles());
    }
  }

  void _selectCategory(NewsCategory category) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    context.read<RemoteArticlesBloc>().add(GetArticles(category: category));
  }

  Future<void> _refresh(NewsCategory category) async {
    final done = Completer<RefreshOutcome>();
    context.read<RemoteArticlesBloc>().add(
          GetArticles(category: category, refresh: true, completer: done),
        );
    final outcome = await done.future;
    if (!mounted) return;
    // New stories speak for themselves; say something only when the list
    // looks exactly the same, so the pull doesn't seem to have done nothing.
    switch (outcome) {
      case RefreshOutcome.nothingNew:
        AppToast.show(context, message: context.l10n.noNewStories);
      case RefreshOutcome.offline:
        AppToast.show(context, message: context.l10n.offlineNothingUpdated);
      case RefreshOutcome.rateLimited:
        AppToast.show(context,
            message: context.l10n.rateLimitedNothingUpdated);
      case RefreshOutcome.failed:
        AppToast.show(context,
            message: context.l10n.refreshFailed, type: AppToastType.error);
      case RefreshOutcome.newStories:
        break;
    }
  }

  void _openArticle(ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      // Coming back online doesn't make the screen forget it was showing a
      // saved/stale copy -- without asking again, the section on screen
      // (and the banner) would just sit there looking offline forever,
      // since nothing else about being back online alone changes what's
      // already cached in RemoteArticlesBloc.
      listenWhen: (previous, current) => !previous.isOnline && current.isOnline,
      listener: (context, _) {
        final bloc = context.read<RemoteArticlesBloc>();
        bloc.add(GetArticles(category: bloc.state.category, refresh: true));
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
            // Masthead and ticker stay put; only the stories scroll.
            builder: (context, state) => Column(
              children: [
                NewsMasthead(
                  onTap: _scrollToTop,
                  onSearch: () => Navigator.pushNamed(context, '/Search'),
                ),
                // The strip itself never disappears once past the very first
                // frame -- loading shows a shimmering placeholder in the same
                // spot, so switching category (or waiting for the first load)
                // reads as "the headline is changing", not as the whole strip
                // popping away and back. AnimatedSize only kicks in for the
                // rare case there's truly nothing to show (an empty or failed
                // section), and it's the same rule for every category.
                _StableTop(child: _LatestStrip(state: state, onOpen: _openArticle)),
                _StableTop(child: _OfflineStrip(state: state)),
                Expanded(child: _buildFeed(context, state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeed(BuildContext context, RemoteArticlesState state) {
    return RefreshIndicator(
      onRefresh: () => _refresh(state.category),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: CategoryBar(
              selected: state.category,
              onSelected: _selectCategory,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ..._buildContent(context, state),
          // Clears the floating tab bar.
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, RemoteArticlesState state) {
    return switch (state) {
      RemoteArticlesDone() => _buildStories(context, state),
      RemoteArticlesError() => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _FeedMessage(
              icon: Icons.cloud_off_outlined,
              title: context.l10n.newsLoadFailed,
              action: FilledButton.tonal(
                onPressed: () => _refresh(state.category),
                child: Text(context.l10n.tryAgain),
              ),
            ),
          ),
        ],
      _ => const [SliverToBoxAdapter(child: _FeedSkeleton())],
    };
  }

  List<Widget> _buildStories(BuildContext context, RemoteArticlesDone state) {
    final articles = state.articles;
    if (articles.isEmpty) {
      return [SliverToBoxAdapter(child: _CaughtUp())];
    }
    final featured = articles
        .where((article) => (article.urlToImage ?? '').isNotEmpty)
        .take(_featuredCount)
        .toList();
    final rest =
        articles.where((article) => !featured.contains(article)).toList();
    final isOffline = state.savedAt != null;
    return [
      if (featured.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: context.l10n.featuredStories),
        ),
        SliverToBoxAdapter(
          child: FeaturedCarousel(
            articles: featured,
            onArticlePressed: _openArticle,
            isOffline: isOffline,
          ),
        ),
      ],
      if (rest.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: context.l10n.todaysStories),
        ),
        SliverToBoxAdapter(
          child: LeadStory(
            article: rest.first,
            onTap: () => _openArticle(rest.first),
          ),
        ),
        SliverList.separated(
          itemCount: rest.length - 1,
          separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
          itemBuilder: (context, index) {
            final article = rest[index + 1];
            return StoryRow(
              article: article,
              onTap: () => _openArticle(article),
              isOffline: isOffline,
            );
          },
        ),
      ],
      SliverToBoxAdapter(child: _buildFooter(state)),
    ];
  }

  Widget _buildFooter(RemoteArticlesDone state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    // Offline there's only the saved first page; the banner explains why,
    // so "you're all caught up" would be misleading.
    final showEnd = state.hasReachedEnd && state.savedAt == null;
    return showEnd ? _CaughtUp() : const SizedBox.shrink();
  }

}

/// Smoothly collapses to nothing and back, instead of a widget just
/// vanishing and reappearing -- see the comment where this is used.
class _StableTop extends StatelessWidget {
  final Widget child;

  const _StableTop({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}

// ISO 8601 timestamps from NewsAPI sort correctly as plain strings.
ArticleEntity _mostRecentArticle(List<ArticleEntity> articles) {
  return articles.reduce((a, b) =>
      (a.publishedAt ?? '').compareTo(b.publishedAt ?? '') >= 0 ? a : b);
}

/// The strip at the very top: a shimmering placeholder while a section is
/// loading, the real headline once it's in, and nothing only when a
/// section is genuinely empty or failed. Crossfades between the three, so
/// a headline changing (new category, or a refresh bringing fresh news)
/// reads as the text changing in place, never as the strip disappearing.
class _LatestStrip extends StatelessWidget {
  final RemoteArticlesState state;
  final ValueChanged<ArticleEntity> onOpen;

  const _LatestStrip({required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final s = state;
    Widget content;
    Object contentKey;
    if (s is RemoteArticlesDone && s.articles.isNotEmpty) {
      final latest = _mostRecentArticle(s.articles);
      content = LatestTicker(article: latest, onTap: () => onOpen(latest));
      contentKey = latest.url ?? latest.title ?? 'latest';
    } else if (s is RemoteArticlesLoading) {
      content = const _LatestTickerSkeleton();
      contentKey = '_loading';
    } else {
      content = const SizedBox.shrink();
      contentKey = '_empty';
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(contentKey), child: content),
    );
  }
}

/// Same shape as [LatestTicker] -- dark strip, badge, one line -- but
/// shimmering in place of real text, so the strip settles into the real
/// ticker once it arrives instead of popping in from nothing.
class _LatestTickerSkeleton extends StatelessWidget {
  const _LatestTickerSkeleton();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.tickerSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer(
          child: Row(
            children: [
              const ShimmerBox(width: 52, height: 20),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The offline strip: shown when the current section is a saved copy
/// (state.savedAt), or when the device has genuinely lost its connection
/// right now, even mid-read with nothing new being fetched. Prefers the
/// real saved-copy time when there is one; otherwise shows since when the
/// connection dropped.
class _OfflineStrip extends StatelessWidget {
  final RemoteArticlesState state;

  const _OfflineStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, connectivity) {
        final done = state is RemoteArticlesDone ? state as RemoteArticlesDone : null;
        final savedAt = done?.savedAt;
        final time = savedAt ?? (connectivity.isOnline ? null : connectivity.offlineSince);
        if (time == null) return const SizedBox.shrink();
        // Only meaningful when savedAt is what's actually driving the
        // banner -- not the reactive "offline right now" case above, which
        // has nothing to do with NewsAPI's own daily cap.
        final isRateLimited = savedAt != null && (done?.isRateLimited ?? false);
        return _OfflineBanner(savedAt: time, isRateLimited: isRateLimited);
      },
    );
  }
}

/// Stands in for the feed while a section loads, in roughly the shape
/// it'll load into -- a featured card, then a few story rows -- so the
/// layout doesn't jump once real stories arrive, and it reads as "here it
/// comes" instead of a bare spinner.
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: ShimmerBox(width: 160, height: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerBox(
              width: double.infinity,
              height: 220,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: ShimmerBox(width: 140, height: 16),
          ),
          for (var i = 0; i < 4; i++) const _SkeletonRow(),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 90, height: 12),
                const SizedBox(height: 8),
                const ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 6),
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  height: 16,
                ),
                const SizedBox(height: 8),
                const ShimmerBox(width: 70, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ShimmerBox(
            width: 96,
            height: 96,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ],
      ),
    );
  }
}

class _CaughtUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: _FeedMessage(
        icon: Icons.check_circle_outline,
        title: context.l10n.allCaughtUp,
        detail: context.l10n.allCaughtUpDetail,
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;

  const _FeedMessage({
    required this.icon,
    required this.title,
    this.detail,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(detail!,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// A thin strip saying the stories on screen are a copy, not live -- either
/// the saved one kept on the phone, or just-loaded stories the reader is
/// still looking at after the connection dropped. See [_OfflineStrip].
class _OfflineBanner extends StatelessWidget {
  final DateTime savedAt;

  /// NewsAPI's free-plan daily cap, not a real connectivity problem --
  /// says so instead of blaming the reader's connection for it.
  final bool isRateLimited;

  const _OfflineBanner({required this.savedAt, this.isRateLimited = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateUtils.isSameDay(savedAt, DateTime.now());
    final time =
        (today ? DateFormat.jm() : DateFormat.MMMd().add_jm()).format(savedAt);
    return ColoredBox(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(
                isRateLimited
                    ? Icons.hourglass_bottom_outlined
                    : Icons.cloud_off_outlined,
                size: 16,
                color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isRateLimited
                    ? context.l10n.newsLimitReachedBanner(time)
                    : context.l10n.offlineBanner(time),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
