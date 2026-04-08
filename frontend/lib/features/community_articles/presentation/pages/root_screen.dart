import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/community_feed_page.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _tabs = <Widget>[
    DailyNews(),
    CommunityFeedPage(),
  ];

  void _openPublish() {
    final cubit = context.read<CommunityFeedCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const PublishArticlePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Daily News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Community',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPublish,
        child: const Icon(Icons.add),
      ),
    );
  }
}
