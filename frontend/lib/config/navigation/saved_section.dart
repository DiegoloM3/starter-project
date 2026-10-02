import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import '../../features/daily_news/presentation/screens/saved_articles/saved_articles_screen.dart';
import '../../features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_cubit.dart';
import '../../features/journalist_articles/presentation/screens/saved_journalist_articles/saved_journalist_articles_screen.dart';
import '../../injection_container.dart';

/// Saved section: the news saved on the phone and the journalists' articles saved in the account, in two tabs
/// like the home section.
///
/// It joins two features, so it is built here (see [HomeSection]'s note). Its blocs are created every time the
/// section opens, so the saved articles are always up to date.
class SavedSection extends StatelessWidget {
  const SavedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalArticlesBloc>(create: (_) => sl()..add(const GetSavedArticles())),
        BlocProvider<SavedJournalistArticlesCubit>(create: (_) => sl()..loadSavedArticles()),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // A section of the bottom navigation bar, so it has no back button.
            automaticallyImplyLeading: false,
            title: const Text('Saved Articles'),
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
              SavedArticlesScreen(),
              SavedJournalistArticlesScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
