import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_filter/news_filter_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_tab/news_tab_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/article_section_helper.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/date_formatter.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/buttons/fab_button.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/cards/card_news.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip_bar.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/headers/expandable_search_header.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/tabs/provider_tabs.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_avatar.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/section_badge.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({super.key});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  final _firestoreScrollController = ScrollController();
  final _remoteScrollController = ScrollController();
  bool _showScrollToTop = false;

  static const _scrollToTopThreshold = 400.0;
  static const _loadMoreThreshold = 200.0;
  static const _animationDurationMillis = 200;
  static const _scrollAnimationMillis = 400;

  @override
  void initState() {
    super.initState();
    _firestoreScrollController.addListener(_onScrollChanged);
    _remoteScrollController.addListener(_onScrollChanged);
    _remoteScrollController.addListener(_onRemoteScrollNearBottom);
  }

  @override
  void dispose() {
    _firestoreScrollController.dispose();
    _remoteScrollController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    final selectedTab = context.read<NewsTabCubit>().state;
    final controller =
        selectedTab == 0 ? _firestoreScrollController : _remoteScrollController;
    final shouldShow = controller.hasClients &&
        controller.offset > _scrollToTopThreshold;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _onRemoteScrollNearBottom() {
    if (!_remoteScrollController.hasClients) return;
    final maxScroll = _remoteScrollController.position.maxScrollExtent;
    final currentScroll = _remoteScrollController.offset;
    if (maxScroll - currentScroll <= _loadMoreThreshold) {
      final bloc = context.read<RemoteArticlesBloc>();
      if (bloc.state.hasMore && bloc.state is! RemoteArticlesLoadingMore) {
        bloc.add(const LoadMoreArticles());
      }
    }
  }

  void _scrollToTop() {
    final selectedTab = context.read<NewsTabCubit>().state;
    final controller =
        selectedTab == 0 ? _firestoreScrollController : _remoteScrollController;
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: _scrollAnimationMillis),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localState = context.watch<LocalArticleBloc>().state;
    final firestoreState = context.watch<FirestoreArticlesBloc>().state;
    final selectedTab = context.watch<NewsTabCubit>().state;
    context.watch<NewsFilterCubit>();
    final savedUrls = _savedUrlsFrom(localState);

    return Scaffold(
      backgroundColor: context.colors.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                _buildTabs(context, selectedTab),
                if (selectedTab == 0) ...[
                  _buildSectionChips(context),
                  const SizedBox(height: AppDimensions.spacing12),
                ],
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: _animationDurationMillis,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(selectedTab),
                      child: selectedTab == 0
                          ? _buildFirestoreContent(
                              context, firestoreState, savedUrls)
                          : _buildRemoteContent(context, savedUrls),
                    ),
                  ),
                ),
              ],
            ),
            _buildFabs(context, selectedTab),
          ],
        ),
      ),
    );
  }

  Set<String> _savedUrlsFrom(LocalArticlesState state) {
    if (state is! LocalArticlesDone) return {};
    return (state.articles ?? [])
        .where((a) => a.url != null)
        .map((a) => a.url!)
        .toSet();
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpandableSearchHeader(
      title: l10n.dailyNewsTitle,
      searchHint: l10n.searchNewsHint,
      cancelLabel: l10n.cancelAction,
      searchButtonLabel: l10n.searchButtonLabel,
      onSearchChanged: (query) {
        context.read<NewsFilterCubit>().updateSearchQuery(query);
      },
      actions: Semantics(
        button: true,
        label: l10n.profileButtonLabel,
        child: GestureDetector(
          onTap: () => _onProfileTap(context),
          child: const AppAvatar(),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, int selectedTab) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        0,
        AppDimensions.spacing24,
        AppDimensions.spacing12,
      ),
      child: ProviderTabs(
        selectedIndex: selectedTab,
        onTabChanged: (index) => context.read<NewsTabCubit>().selectTab(index),
        items: [
          ProviderTabItem(
            label: l10n.myNewsTab,
            icon: Icons.edit_outlined,
          ),
          ProviderTabItem(
            label: l10n.worldNewsTab,
            icon: Icons.public,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionChips(BuildContext context) {
    final filterState = context.read<NewsFilterCubit>().state;
    final l10n = AppLocalizations.of(context)!;

    return SectionChipBar<NewsSection>(
      items: NewsSection.values,
      selectedItem: filterState.selectedSection,
      onItemChanged: (section) {
        context.read<NewsFilterCubit>().selectSection(section);
      },
      labelBuilder: (section) => section.label(l10n),
    );
  }

  Widget _buildFirestoreContent(
    BuildContext context,
    FirestoreArticlesState state,
    Set<String> savedUrls,
  ) {
    if (state is FirestoreArticlesLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (state is FirestoreArticlesError) {
      return _buildErrorState(context);
    }
    if (state is FirestoreArticlesDone) {
      final filterState = context.read<NewsFilterCubit>().state;
      final articles = filterArticles(
        articles: state.articles ?? [],
        selectedSection: filterState.selectedSection,
        searchQuery: filterState.searchQuery,
      );
      if (articles.isEmpty) {
        return _buildEmptyState(
          context,
          AppLocalizations.of(context)!.noSavedArticles,
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          context
              .read<FirestoreArticlesBloc>()
              .add(const GetFirestoreArticles());
        },
        child: _buildArticleList(
          context,
          articles,
          savedUrls,
          _firestoreScrollController,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRemoteContent(BuildContext context, Set<String> savedUrls) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is RemoteArticlesError) {
          return _buildErrorState(context);
        }
        if (state is RemoteArticlesDone ||
            state is RemoteArticlesCached ||
            state is RemoteArticlesLoadingMore) {
          final filterState = context.read<NewsFilterCubit>().state;
          final articles = filterArticles(
            articles: state.articles ?? [],
            selectedSection: filterState.selectedSection,
            searchQuery: filterState.searchQuery,
          );
          if (articles.isEmpty && state is! RemoteArticlesLoadingMore) {
            return _buildEmptyState(
              context,
              AppLocalizations.of(context)!.noNewsAvailable,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RemoteArticlesBloc>().add(const GetArticles());
            },
            child: Column(
              children: [
                if (state is RemoteArticlesCached)
                  _buildOfflineBanner(context),
                Expanded(
                  child: _buildArticleList(
                    context,
                    articles,
                    savedUrls,
                    _remoteScrollController,
                    showLoadingMore: state is RemoteArticlesLoadingMore,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildArticleList(
    BuildContext context,
    List<ArticleEntity> articles,
    Set<String> savedUrls,
    ScrollController scrollController, {
    bool showLoadingMore = false,
  }) {
    final filterState = context.read<NewsFilterCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final showBadge = filterState.selectedSection == NewsSection.all;
    final colors = context.colors;
    final itemCount = articles.length + (showLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        0,
        AppDimensions.spacing24,
        AppDimensions.fabSize +
            AppDimensions.spacing24 +
            AppDimensions.spacing14,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacing14),
      itemBuilder: (_, index) {
        if (index >= articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final article = articles[index];
        final isBookmarked = savedUrls.contains(article.url);
        final section = article.section;

        final imageUrl = article.images.isNotEmpty
            ? article.images.first
            : article.urlToImage;

        return CardNews(
          title: article.title ?? '',
          description: article.description,
          date: formatArticleDate(article.publishedAt),
          imageUrl: imageUrl,
          isBookmarked: isBookmarked,
          sectionBadge: showBadge && section != null
              ? SectionBadge(
                  label: section.label(l10n),
                  backgroundColor: section.backgroundColor(colors),
                  textColor: section.textColor(colors),
                )
              : null,
          onBookmarkTap: () => _onBookmarkTap(context, article, isBookmarked),
          onTap: () => _onArticleTap(context, article),
        );
      },
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing10,
      ),
      decoration: BoxDecoration(
        color: colors.weatherSectionBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: AppDimensions.iconSm,
            color: colors.weatherSectionText,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Expanded(
            child: Text(
              l10n.offlineBanner,
              style: AppTypography.subtitle.copyWith(
                color: colors.weatherSectionText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: AppDimensions.iconHero,
            color: colors.textPlaceholder,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            message,
            style: AppTypography.subtitle.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: AppDimensions.iconHero,
            color: AppColors.destructive,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            l10n.newsLoadError,
            style: AppTypography.subtitle.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          SecondaryButton(
            label: l10n.retryAction,
            icon: Icons.refresh,
            onPressed: () => _onRetry(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFabs(BuildContext context, int selectedTab) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      right: AppDimensions.spacing24,
      bottom: AppDimensions.spacing24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _showScrollToTop ? 1.0 : 0.0,
            duration: const Duration(milliseconds: _animationDurationMillis),
            child: AnimatedOpacity(
              opacity: _showScrollToTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: _animationDurationMillis),
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: Semantics(
                  button: true,
                  label: l10n.scrollToTopButtonLabel,
                  child: FabButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: _scrollToTop,
                  ),
                ),
              ),
            ),
          ),
          if (selectedTab == 0)
            Semantics(
              button: true,
              label: l10n.addNewsButtonLabel,
              child: FabButton(onPressed: () => _onAddNewsTap(context)),
            ),
        ],
      ),
    );
  }

  void _onProfileTap(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.profile);
  }

  Future<void> _onAddNewsTap(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.addNews);
    if (result == true && context.mounted) {
      context
          .read<FirestoreArticlesBloc>()
          .add(const GetFirestoreArticles());
    }
  }

  Future<void> _onArticleTap(
      BuildContext context, ArticleEntity article) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.articleDetails,
      arguments: article,
    );
    if (result == true && context.mounted) {
      context
          .read<FirestoreArticlesBloc>()
          .add(const GetFirestoreArticles());
    }
  }

  void _onBookmarkTap(
    BuildContext context,
    ArticleEntity article,
    bool isCurrentlyBookmarked,
  ) {
    final bloc = context.read<LocalArticleBloc>();
    if (isCurrentlyBookmarked) {
      final localState = bloc.state;
      if (localState is LocalArticlesDone) {
        final localArticle = (localState.articles ?? []).firstWhere(
          (a) => a.url == article.url,
          orElse: () => article,
        );
        bloc.add(RemoveArticle(localArticle));
      }
    } else {
      bloc.add(SaveArticle(article));
    }
  }

  void _onRetry(BuildContext context) {
    final selectedTab = context.read<NewsTabCubit>().state;
    if (selectedTab == 0) {
      context
          .read<FirestoreArticlesBloc>()
          .add(const GetFirestoreArticles());
    } else {
      context.read<RemoteArticlesBloc>().add(const GetArticles());
    }
  }
}
