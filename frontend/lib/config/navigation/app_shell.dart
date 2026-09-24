import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../features/authentication/presentation/bloc/session/session_cubit.dart';
import '../../features/authentication/presentation/screens/account/account_screen.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import '../../features/daily_news/presentation/screens/home/daily_news.dart';
import '../../features/daily_news/presentation/screens/saved_article/saved_article.dart';
import '../../features/journalist_articles/domain/use_cases/get_published_articles.dart';
import '../../features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/article_byline/article_byline_cubit.dart';
import '../../features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_cubit.dart';
import '../../features/journalist_articles/presentation/screens/article_feed/article_feed_screen.dart';
import '../../injection_container.dart';
import '../theme/design_tokens.dart';

/// The four tabs the app is organised around.
///
/// It replaces the row of unlabelled icons the app bar used to carry: every
/// destination now says what it is, which is the difference between an app
/// somebody can learn and one they have to be taught.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Where Account sits in [_destinationsFor]. Named so the two places that
  /// care — the tab that refreshes its numbers and the one that hides the
  /// Write button — do not both hard-code a 3.
  static const int _accountTab = 3;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Read once, here, because the saved list is shared: the reader needs it
    // to know whether the article in front of it is already saved, and the
    // Saved tab needs it to show the list. Both read the same bloc.
    sl<LocalArticleBloc>().add(const GetSavedArticles());
  }

  List<_Destination> _destinationsFor(AppLocalizations l10n) => [
        _Destination(
          label: l10n.navNews,
          icon: Icons.article_outlined,
          selectedIcon: Icons.article,
        ),
        _Destination(
          label: l10n.navCommunity,
          icon: Icons.forum_outlined,
          selectedIcon: Icons.forum,
        ),
        _Destination(
          label: l10n.navSaved,
          icon: Icons.bookmark_border,
          selectedIcon: Icons.bookmark,
        ),
        _Destination(
          label: l10n.navAccount,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
      ];

  /// Moves to a tab, and does the two things leaving one implies.
  void _onTabSelected(int index) {
    // A snack bar belongs to the screen that raised it. The messenger is the
    // shell's, and the tabs are kept alive in an IndexedStack, so "Removed
    // from saved · Undo" followed the reader into News and sat there offering
    // to undo something they could no longer see.
    ScaffoldMessenger.of(context).clearSnackBars();

    if (index == _accountTab) {
      _refreshAccountSummary();
    }

    setState(() => _currentIndex = index);
  }

  /// Re-reads the account summary on the way into the tab that shows it.
  ///
  /// The numbers are a snapshot, and this tab is kept alive behind the
  /// others: publishing an article or being read by somebody moves them on
  /// the backend while the screen goes on showing what it read at startup.
  void _refreshAccountSummary() {
    final user = context.read<SessionCubit>().state.user;
    final stats = sl<JournalistStatsCubit>();

    if (user == null) {
      stats.clear();
      return;
    }

    stats.loadFor(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DailyNews(),
          // Composed here, as in AppRoutes, so the screen never reaches for
          // the injection container itself.
          BlocProvider<ArticleFeedCubit>(
            create: (_) =>
                ArticleFeedCubit(sl<GetPublishedArticlesUseCase>())..loadFeed(),
            child: const ArticleFeedScreen(),
          ),
          // `.value`, never `create`: BlocProvider closes what it creates, and
          // this bloc is a singleton the rest of the app still needs.
          BlocProvider<LocalArticleBloc>.value(
            value: sl<LocalArticleBloc>(),
            child: const SavedArticles(),
          ),
          MultiBlocProvider(
            providers: [
              BlocProvider<JournalistStatsCubit>.value(
                value: sl<JournalistStatsCubit>(),
              ),
              BlocProvider<ArticleBylineCubit>.value(
                value: sl<ArticleBylineCubit>(),
              ),
            ],
            child: const AccountScreen(),
          ),
        ],
      ),
      // Writing is offered from the two reading tabs. It is absent from Saved
      // and Account, where it would have nothing to do with what is on screen.
      floatingActionButton: _currentIndex <= 1 ? const WriteButton() : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          for (final destination
              in _destinationsFor(AppLocalizations.of(context)))
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

/// The way into the editor, from anywhere a person is reading.
///
/// Without an account it opens the invitation sheet instead of failing: the
/// answer to "can I write?" is never a silent nothing.
class WriteButton extends StatelessWidget {
  const WriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _onPressed(context),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit_outlined, size: 20),
      label: Text(
        AppLocalizations.of(context).actionWrite,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final isSignedIn = context.read<SessionCubit>().state.isSignedIn;

    if (isSignedIn) {
      Navigator.pushNamed(context, '/ArticleEditor');
      return;
    }

    Navigator.pushNamed(context, '/SignIn');
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
