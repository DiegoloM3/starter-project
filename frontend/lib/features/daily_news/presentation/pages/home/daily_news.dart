import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentTab,
        children: const [
          _FeedTab(),
          SearchPage(embedded: true),
          SavedArticles(embedded: true),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
        backgroundColor: AppColors.red,
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

  static const _tabs = [
    _TabDef(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Feed'),
    _TabDef(icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
    _TabDef(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: 'Saved'),
    _TabDef(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
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
                        color: isActive ? AppColors.red : AppColors.t2,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: AppTypography.sans(
                          fontSize: 9.5,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive ? AppColors.red : AppColors.t2,
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
    return Column(
      children: [
        // Safe area for status bar
        Container(
          color: AppColors.surface,
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
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          // Red rule marker + wordmark
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Simmetry',
            style: AppTypography.serif(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
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

    return ListView(
      children: [
        // Lead story — feature card
        FeatureCard(
          article: featured,
          onTap: () => Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: featured,
          ),
        ),
        // Section header
        if (rest.isNotEmpty) _buildSectionHeader(l10n),
        // Rest of articles
        for (int i = 0; i < rest.length; i++)
          ArticleWidget(
            article: rest[i],
            showDivider: i < rest.length - 1,
            onArticlePressed: (a) =>
                Navigator.pushNamed(context, '/ArticleDetails', arguments: a),
          ),
        // Bottom padding so FAB doesn't overlap last item
        const SizedBox(height: 80),
      ],
    );
  }

  /// Editorial section header: red rule + "LATEST" + divider line
  Widget _buildSectionHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'LATEST',
            style: AppTypography.sans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: AppColors.t2,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(height: 1, color: AppColors.border),
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
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email ?? '';
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
          color: AppColors.surface,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile',
                style: AppTypography.serif(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.t1,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 24),
              // User info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: AppTypography.sans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: AppTypography.serif(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.border),
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
              const Divider(height: 1, color: AppColors.border),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: 'Sign out',
                color: AppColors.error,
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
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.t1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.t3),
          ],
        ),
      ),
    );
  }
}
