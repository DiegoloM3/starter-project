import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/user_articles/presentation/bloc/feed/user_articles_feed_cubit.dart';
import '../../features/user_articles/presentation/screens/user_articles_feed_screen.dart';
import '../../injection_container.dart';
import '../../shared/account/presentation/bloc/account_cubit.dart';
import '../../shared/account/presentation/screens/profile_screen.dart';
import '../locale/language_tile.dart';
import '../theme/theme_mode_tile.dart';
import 'floating_tab_bar.dart';

/// The app's 4 top-level destinations (News / My Articles / Saved / Profile)
/// as tabs behind one floating bar, with "+" in its middle. Each tab keeps
/// its own nested Scaffold/AppBar; IndexedStack (not a PageView or
/// rebuilding the selected screen) keeps every tab's scroll position and
/// loaded state alive while it's hidden.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _myArticlesTabIndex = 1;

  // Owned here, not by the My Articles tab, so the bar's "+" can refresh
  // that feed after publishing from any tab.
  final UserArticlesFeedCubit _userArticlesFeedCubit = sl();
  final AccountCubit _accountCubit = sl();
  int _selectedIndex = 0;

  static const _newsTabIndex = 0;

  // Tapping News while already on News scrolls it back to the top.
  final _scrollNewsToTop = _TapSignal();

  @override
  void dispose() {
    unawaited(_userArticlesFeedCubit.close());
    unawaited(_accountCubit.close());
    _scrollNewsToTop.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _newsTabIndex && _selectedIndex == _newsTabIndex) {
      _scrollNewsToTop.fire();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _openNewArticleForm() async {
    final published = await Navigator.pushNamed(context, '/UserArticleForm');
    if (published != true || !mounted) return;
    _selectTab(_myArticlesTabIndex);
    unawaited(_userArticlesFeedCubit.loadArticles());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserArticlesFeedCubit>.value(
            value: _userArticlesFeedCubit),
        BlocProvider<AccountCubit>.value(value: _accountCubit),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            DailyNews(scrollToTop: _scrollNewsToTop),
            const UserArticlesFeedScreen(),
            const SavedArticles(),
            const ProfileScreen(sections: [ThemeModeTile(), LanguageTile()]),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: FloatingTabBar(
          selectedIndex: _selectedIndex,
          onTabSelected: _selectTab,
          onCreatePressed: _openNewArticleForm,
        ),
      ),
    );
  }
}

/// A bare "it happened" signal for listeners, with no value to carry.
class _TapSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}
