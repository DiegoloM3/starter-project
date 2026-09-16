import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/saved_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/search_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/profile_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/navigation/glass_nav_bar.dart';

/// The four tabs behind the glass bar. Pages live in an [IndexedStack] so
/// switching keeps each tab's scroll position, and the body runs under the
/// bar so content shows through the frost.
class HomeShellScreen extends StatefulWidget {
  final int initialTab;

  const HomeShellScreen({super.key, this.initialTab = 0});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late int _index = widget.initialTab.clamp(0, _tabs.length - 1);

  @override
  void didUpdateWidget(HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _index = widget.initialTab.clamp(0, _tabs.length - 1);
  }

  static const _tabs = [
    GlassNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search'),
    GlassNavItem(icon: Icons.bookmark_outline_rounded, activeIcon: Icons.bookmark_rounded, label: 'Saved'),
    GlassNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), SearchScreen(), SavedScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: GlassNavBar(
        items: _tabs,
        selectedIndex: _index,
        onSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
