import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/skeleton_article_tile.dart';
import '../../widgets/skeleton_feature_card.dart';
import '../saved_article/saved_article.dart';
import '../search/search_page.dart';

/// Main shell: bottom nav with Feed / Search / Saved / Profile tabs.
class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      body: IndexedStack(
        index: _currentTab,
        children: [
          const _FeedTab(),
          const SearchPage(embedded: true),
          SavedArticles(embedded: true, isActive: _currentTab == 2),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
        backgroundColor: cs.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation — editorial style with red rule marker on active tab
// ---------------------------------------------------------------------------
class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.activeIndex, required this.onTap});

  static const _icons = [
    _TabDef(icon: Icons.home_outlined, activeIcon: Icons.home, label: ''),
    _TabDef(icon: Icons.search, activeIcon: Icons.search, label: ''),
    _TabDef(icon: Icons.bookmark_border, activeIcon: Icons.bookmark, label: ''),
    _TabDef(icon: Icons.person_outline, activeIcon: Icons.person, label: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.tabFeed, l10n.tabSearch, l10n.tabSaved, l10n.tabProfile];
    return Container(
      height: 58 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: List.generate(_icons.length, (i) {
          final tab = _icons[i];
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 21,
                        color: isActive ? cs.primary : cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        labels[i],
                        style: tt.labelSmall?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive ? cs.primary : cs.onSurfaceVariant,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabDef {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabDef(
      {required this.icon, required this.activeIcon, required this.label});
}

// ---------------------------------------------------------------------------
// Feed Tab — AppBar + articles list with feature card
// ---------------------------------------------------------------------------
class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Safe area for status bar
        Container(
          color: cs.surface,
          child: SafeArea(
            bottom: false,
            child: _buildAppBar(context),
          ),
        ),
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      padding: const EdgeInsets.only(left: AppSpacing.gutter, right: 6),
      child: Row(
        children: [
          // Red rule marker + wordmark
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.appName,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoading) {
          return _buildLoadingState();
        }
        if (state is FeedFailure) {
          return _buildErrorState(context, state);
        }
        if (state is FeedDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildLoadedState(context, articles);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      children: [
        const SkeletonFeatureCard(),
        const SizedBox(height: 6),
        for (int i = 0; i < 5; i++)
          SkeletonArticleTile(showDivider: i < 4),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, FeedFailure state) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.warning_amber_rounded,
      title: l10n.somethingWentWrong,
      subtitle: state.error?.message ?? l10n.couldNotLoadArticles,
      actionLabel: l10n.tryAgain,
      onAction: () {
        context.read<FeedBloc>().add(const FeedSubscriptionRequested());
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: l10n.noArticlesTitle,
      subtitle: l10n.noArticlesSubtitle,
      actionLabel: l10n.writeTheFirstArticle,
      onAction: () => Navigator.pushNamed(context, '/CreateArticle'),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, List<ArticleEntity> articles) {
    final l10n = AppLocalizations.of(context)!;
    final featured = articles.first;
    final rest = articles.length > 1 ? articles.sublist(1) : <ArticleEntity>[];

    // Leading slots before the article list:
    //   0 -> lead story feature card
    //   1 -> section header (only when there are more articles)
    // Trailing slot:
    //   last -> bottom padding so the FAB doesn't overlap the last item.
    final headerOffset = rest.isNotEmpty ? 2 : 1;
    final itemCount = headerOffset + rest.length + 1;

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Lead story — feature card
          return FeatureCard(
            article: featured,
            onTap: () => Navigator.pushNamed(
              context,
              '/ArticleDetails',
              arguments: featured,
            ),
          );
        }
        if (rest.isNotEmpty && index == 1) {
          // Section header
          return _buildSectionHeader(context, l10n);
        }
        if (index == itemCount - 1) {
          // Bottom padding so FAB doesn't overlap last item
          return const SizedBox(height: 80);
        }
        final restIndex = index - headerOffset;
        return ArticleWidget(
          article: rest[restIndex],
          showDivider: restIndex < rest.length - 1,
          onArticlePressed: (a) =>
              Navigator.pushNamed(context, '/ArticleDetails', arguments: a),
        );
      },
    );
  }

  /// Editorial section header: red rule + "LATEST" + divider line
  Widget _buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 14, AppSpacing.gutter, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.sectionLatest,
            style: tt.labelSmall?.copyWith(
              letterSpacing: 2.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(height: 1, color: cs.outline),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Tab — My Articles, Drafts, Logout
// ---------------------------------------------------------------------------
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    final authUser =
        authState is AuthAuthenticated ? authState.user : null;
    final displayName = authUser?.displayName ?? authUser?.email ?? '';
    final initials = displayName.isNotEmpty
        ? displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Column(
      children: [
        Container(
          color: cs.surface,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(bottom: BorderSide(color: cs.outline)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.tabProfile,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: AppSpacing.xl2),
              // User info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: tt.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      displayName,
                      style: tt.headlineSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              Divider(height: 1, color: cs.outline),
              // Menu items
              _ProfileMenuItem(
                icon: Icons.article_outlined,
                label: l10n.myArticles,
                onTap: () => Navigator.pushNamed(context, '/MyArticles'),
              ),
              _ProfileMenuItem(
                icon: Icons.edit_note,
                label: l10n.myDrafts,
                onTap: () => Navigator.pushNamed(context, '/Drafts'),
              ),
              _ProfileMenuItem(
                icon: Icons.bookmark_border,
                label: l10n.savedArticles,
                onTap: () => Navigator.pushNamed(context, '/SavedArticles'),
              ),
              Divider(height: 1, color: cs.outline),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: l10n.signOut,
                color: cs.error,
                onTap: () => context
                    .read<AuthBloc>()
                    .add(const AuthSignOutRequested()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = this.color ?? cs.onSurface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.outlineVariant),
          ],
        ),
      ),
    );
  }
}
