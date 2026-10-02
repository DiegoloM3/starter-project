import 'package:flutter/material.dart';

import '../../features/daily_news/presentation/screens/daily_news/daily_news_screen.dart';
import '../../features/journalist_articles/presentation/screens/published_articles/published_articles_screen.dart';

/// Home section: the news from NewsAPI and the journalists' articles, in two tabs.
///
/// It joins two features, so it is built here and not inside either of them: a feature only imports its own
/// layers, `core` and `shared` (docs/APP_ARCHITECTURE.md). Its tab controller is provided by the app navigation,
/// which also owns the + button.
class HomeSection extends StatelessWidget {
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily News'),
        bottom: const TabBar(
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Daily News'),
            Tab(text: 'Journalists'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          DailyNewsScreen(),
          PublishedArticlesScreen(),
        ],
      ),
    );
  }
}
