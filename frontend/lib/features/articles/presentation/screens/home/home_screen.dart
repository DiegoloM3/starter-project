import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../shared/users/domain/entities/user.dart';
import '../../../../../injection_container.dart';
import '../../../../profiles/presentation/bloc/user_profile/user_profile_cubit.dart';
import '../../bloc/reading_history/reading_history_cubit.dart';
import '../../../../profiles/presentation/screens/profile/profile_screen.dart';
import '../../bloc/saved_articles/saved_articles_cubit.dart';
import '../../bloc/saved_articles/saved_articles_state.dart';
import '../feed/feed_screen.dart';
import '../saved/saved_screen.dart';
import '../trends/trends_screen.dart';

enum _HomeTab { news, trends, publish, saved, profile }

/// Bottom navigation of the signed in user. Publish, in the center, is only shown to journalists
/// and opens the editor instead of switching tabs.
class HomeScreen extends StatefulWidget {
  final UserEntity user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeTab _currentTab = _HomeTab.news;

  /// Kept here so the profile is refreshed every time its tab is opened, for example after
  /// following someone from another screen.
  late final UserProfileCubit _ownProfileCubit = sl<UserProfileCubit>(param1: widget.user.uid)..load();
  late final ReadingHistoryCubit _readingHistoryCubit = sl<ReadingHistoryCubit>()..load();

  @override
  void dispose() {
    _ownProfileCubit.close();
    _readingHistoryCubit.close();
    super.dispose();
  }

  List<_HomeTab> get _tabs =>
      _HomeTab.values.where((tab) => tab != _HomeTab.publish || widget.user.canPublishArticles).toList();

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    return BlocListener<SavedArticlesCubit, SavedArticlesState>(
      listenWhen: (_, state) => state.status == SavedArticlesStatus.toggleFailure,
      listener:
          (context, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No se pudieron actualizar tus guardados.'))),
      child: Scaffold(
        body: IndexedStack(index: tabs.indexOf(_currentTab), children: tabs.map(_buildTabContent).toList()),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline))),
          child: NavigationBar(
            selectedIndex: tabs.indexOf(_currentTab),
            onDestinationSelected: (index) => _onTabSelected(tabs[index]),
            destinations: tabs.map(_buildDestination).toList(),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(_HomeTab tab) {
    if (tab == _HomeTab.publish) {
      Navigator.of(context).pushNamed(AppRoutes.articleEditor);
    } else {
      if (tab == _HomeTab.profile) _refreshProfile();
      setState(() => _currentTab = tab);
    }
  }

  void _refreshProfile() {
    _ownProfileCubit.load();
    _readingHistoryCubit.load();
  }

  Widget _buildTabContent(_HomeTab tab) => switch (tab) {
    _HomeTab.news => const FeedScreen(),
    _HomeTab.trends => const TrendsScreen(),
    _HomeTab.publish => const SizedBox.shrink(),
    _HomeTab.saved => const SavedScreen(),
    _HomeTab.profile => MultiBlocProvider(
      providers: [BlocProvider.value(value: _ownProfileCubit), BlocProvider.value(value: _readingHistoryCubit)],
      child: const ProfileScreen(),
    ),
  };

  NavigationDestination _buildDestination(_HomeTab tab) => switch (tab) {
    _HomeTab.news => const NavigationDestination(
      icon: Icon(Icons.newspaper_outlined),
      selectedIcon: Icon(Icons.newspaper),
      label: 'Noticias',
    ),
    _HomeTab.trends => const NavigationDestination(icon: Icon(Icons.trending_up), label: 'Tendencias'),
    _HomeTab.publish => const NavigationDestination(icon: Icon(Icons.add_box_outlined, size: 32), label: 'Publicar'),
    _HomeTab.saved => const NavigationDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      label: 'Guardados',
    ),
    _HomeTab.profile => const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  };
}
