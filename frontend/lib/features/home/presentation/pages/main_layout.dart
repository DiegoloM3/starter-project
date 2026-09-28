import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/home/presentation/widgets/sidebar_menu.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/news_home/news_home_page.dart';

/// Shell page hosting the drawer navigation and the news home.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _drawerController = AwesomeDrawerBarController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final slideWidth = screenWidth * 0.78;

    return AwesomeDrawerBar(
      controller: _drawerController,
      type: StyleState.overlay,
      menuScreen: SidebarMenu(
        onItemSelected: () => _drawerController.close?.call(),
      ),
      mainScreen: NewsHomePage(
        onMenuPressed: () => _drawerController.toggle?.call(),
      ),
      borderRadius: 20.0,
      showShadow: true,
      angle: 0.0,
      backgroundColor: const Color(0xFF1E1E24),
      slideWidth: slideWidth.clamp(240.0, 320.0),
    );
  }
}
