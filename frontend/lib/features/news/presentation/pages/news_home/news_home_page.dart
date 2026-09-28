import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/user_avatar.dart';

import 'community_feed_tab.dart';
import 'daily_news_tab.dart';

/// Home screen with daily-news and community tabs plus create shortcut.
class NewsHomePage extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const NewsHomePage({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppbar(context),
        body: const TabBarView(
          children: [
            DailyNewsTab(),
            CommunityFeedTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'newsHomeCreate',
          onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Ionicons.menuOutline, color: Colors.black, size: 26),
        onPressed: () => _openMenu(context),
      ),
      title: const Text(
        'News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
        _buildAuthIndicator(context),
      ],
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Daily News'),
          Tab(text: 'News from Users'),
        ],
      ),
    );
  }

  Widget _buildAuthIndicator(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoggedIn = state is Authenticated;
        final user = isLoggedIn ? state.user : null;

        return GestureDetector(
          onTap: () {
            if (isLoggedIn) {
              _openMenu(context);
            } else {
              Navigator.pushNamed(context, '/Login');
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: Center(
              child: Stack(
                children: [
                  _buildAvatar(isLoggedIn, user),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLoggedIn ? Colors.green : Colors.grey,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isLoggedIn, UserEntity? user) {
    return UserAvatar(
      user: user,
      isLoggedIn: isLoggedIn,
      radius: 15,
    );
  }

  void _openMenu(BuildContext context) {
    if (onMenuPressed != null) {
      onMenuPressed!();
    } else {
      AwesomeDrawerBar.of(context)?.toggle();
    }
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
