import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/screens/profile/profile_screen.dart';
import '../../features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import '../../features/settings/presentation/screens/settings/settings_screen.dart';
import 'app_bottom_navigation_bar.dart';
import 'home_section.dart';
import 'saved_section.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Main screen of the app: shows the section chosen in the bottom navigation bar.
/// The home tabs ("Daily News" | "Journalists") live here so the + button can open "Journalists".
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  static const int _journalistsTabIndex = 1;

  AppSection _currentSection = AppSection.home;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) => Scaffold(
          extendBody: true,
          body: _buildSection(),
          bottomNavigationBar: AppBottomNavigationBar(
            currentSection: _currentSection,
            onSectionSelected: _onSectionSelected,
            onCreatePressed: () => _onCreatePressed(tabContext),
          ),
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_currentSection) {
      case AppSection.home:
        return const HomeSection();
      case AppSection.saved:
        return const SavedSection();
      case AppSection.profile:
        return const ProfileScreen();
      case AppSection.settings:
        return const SettingsScreen();
    }
  }

  void _onSectionSelected(AppSection section) {
    setState(() => _currentSection = section);
  }

  /// Opens the form to publish an article and, once it is published,
  /// shows the journalists' articles with the new one.
  Future<void> _onCreatePressed(BuildContext tabContext) async {
    final publishedArticle = await Navigator.pushNamed(tabContext, RouteNames.publishArticle);
    if (publishedArticle == null || !tabContext.mounted) return;
    tabContext.read<PublishedArticlesCubit>().loadArticles();
    DefaultTabController.of(tabContext).animateTo(_journalistsTabIndex);
    _onSectionSelected(AppSection.home);
  }
}
