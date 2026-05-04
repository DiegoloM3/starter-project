import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

/// Shell scaffold for the two top-level destinations (Home, Settings).
/// Uses Material 3 [NavigationBar] inside [StatefulShellRoute.indexedStack]
/// so each tab keeps its own navigation state when the user switches tabs.
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    // `initialLocation: true` re-routes a re-tap of the active tab back to
    // the branch's root, mirroring the iOS/Material convention.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // M3 default is 80dp — heavy for a 2-destination bar. 64dp keeps
        // the icon + label readable while reclaiming vertical space.
        height: 64,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: t.navSettings,
          ),
        ],
      ),
    );
  }
}
