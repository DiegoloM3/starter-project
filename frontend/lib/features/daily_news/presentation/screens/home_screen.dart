import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_error_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_hero.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_section_header.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/brief_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/category_strip.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/shrinking_write_fab.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/staggered_entrance.dart';

/// Home tab: the masthead, the section strip, Today's Brief, then provider
/// headlines and own articles in one numbered list led by the first story.
/// Reloads whenever the feed settings change.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static NewsQuery queryOf(AppSettings settings) =>
      NewsQuery(category: settings.defaultCategory);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final feed = context.read<FeedCubit>();
    if (feed.state is FeedInitial) {
      feed.load(HomeScreen.queryOf(context.read<SettingsCubit>().state.settings));
    }
  }

  @override
  Widget build(BuildContext context) => const HomeView();
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ValueNotifier<FeedScrollDirection> _scrollDirection = ValueNotifier(
    FeedScrollDirection.idle,
  );

  @override
  void dispose() {
    _scrollDirection.dispose();
    super.dispose();
  }

  /// Every movement hides the Write block; the end of the scroll (or an idle
  /// user) lets it come back.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    _scrollDirection.value = switch (notification) {
      ScrollUpdateNotification(:final scrollDelta?) when scrollDelta > 0 => FeedScrollDirection.down,
      ScrollUpdateNotification(:final scrollDelta?) when scrollDelta < 0 => FeedScrollDirection.up,
      ScrollEndNotification() => FeedScrollDirection.idle,
      UserScrollNotification(direction: ScrollDirection.idle) => FeedScrollDirection.idle,
      _ => _scrollDirection.value,
    };
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.settings.defaultCategory != current.settings.defaultCategory,
      listener: (context, state) =>
          context.read<FeedCubit>().load(HomeScreen.queryOf(state.settings)),
      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: bottomInset - MediaQuery.viewPaddingOf(context).bottom),
          child: ShrinkingWriteFab(
            onPressed: () => context.pushPublish(),
            scrollDirection: _scrollDirection,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<FeedCubit>().refresh();
              if (context.mounted) showAppSnackBar(context, 'Feed updated');
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: BlocBuilder<SessionCubit, SessionState>(
                      builder: (context, state) => state.user == null
                          ? const SizedBox.shrink()
                          : HomeHeader(
                              user: state.user!,
                              now: DateTime.now(),
                              onAvatarTap: context.pushSettings,
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocBuilder<SettingsCubit, SettingsState>(
                      buildWhen: (previous, current) =>
                          previous.settings.defaultCategory != current.settings.defaultCategory,
                      builder: (context, state) => CategoryStrip(
                        selected: state.settings.defaultCategory,
                        onSelected: context.read<SettingsCubit>().setDefaultCategory,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocBuilder<BriefCubit, BriefState>(
                      builder: (context, state) => BriefCard(
                        completedToday: state.isCompletedOn(DateTime.now()),
                        onPressed: context.pushBrief,
                      ),
                    ),
                  ),
                  const _FeedBody(),
                  SliverPadding(padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.huge)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody();

  @override
  Widget build(BuildContext context) {
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) => switch (state) {
        FeedInitial() || FeedLoading() => const SliverToBoxAdapter(child: FeedSkeleton()),
        FeedFailure(:final failure) => SliverToBoxAdapter(
            child: FeedErrorCard(
              message: FailureMessageFormatter.of(failure),
              onRetry: () => context.read<FeedCubit>().load(state.query!),
            ),
          ),
        FeedLoaded() when state.isEmpty => SliverToBoxAdapter(
            child: EmptyState(
              glyph: 'n',
              title: 'Nothing new in ${state.query!.category.label} yet',
              message: 'Try another category, or write the first story yourself.',
              action: SecondaryButton(
                label: 'Change category',
                onPressed: context.pushDefaultCategoryPicker,
              ),
            ),
          ),
        FeedLoaded(:final feed, :final loadedAt) => _LoadedFeed(
            feed: feed,
            loadedAt: loadedAt,
            userId: userId,
            onRetry: () => context.read<FeedCubit>().load(state.query!),
          ),
      },
    );
  }
}

/// The lead story and the section header as one block, then the numbered
/// rows built only as they scroll into view: a feed can hold a hundred
/// articles and every row carries an image and an entrance animation.
class _LoadedFeed extends StatelessWidget {
  final FeedEntity feed;
  final DateTime loadedAt;
  final String? userId;
  final VoidCallback onRetry;

  const _LoadedFeed({required this.feed, required this.loadedAt, required this.userId, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final hasLead = feed.articles.isNotEmpty && feed.remoteFailure == null;
    final rows = [
      for (final (index, article) in feed.articles.indexed)
        if (index > 0 || !hasLead) (index, article),
    ];
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (feed.remoteFailure case final failure?)
                FeedErrorCard(
                  message: '${FailureMessageFormatter.of(failure)} Your own articles are still here below.',
                  onRetry: onRetry,
                ),
              if (hasLead)
                StaggeredEntrance(
                  key: ValueKey('feed-lead-${feed.articles.first.id}'),
                  index: 0,
                  child: FeedHero(
                    article: feed.articles.first,
                    isOwn: feed.articles.first.isOwnedBy(userId),
                    onTap: () => context.pushReader(feed.articles.first),
                  ),
                ),
              FeedSectionHeader(
                title: feed.remoteFailure == null ? 'Latest' : 'Your articles',
                count: feed.articles.length,
                updatedAt: loadedAt,
              ),
            ],
          ),
        ),
        SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, position) {
            final (index, article) = rows[position];
            return StaggeredEntrance(
              key: ValueKey('feed-${article.id}'),
              index: index,
              child: Column(
                children: [
                  FeedItem(
                    article: article,
                    number: index + 1,
                    isOwn: article.isOwnedBy(userId),
                    onTap: () => context.pushReader(article),
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
