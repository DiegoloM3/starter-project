import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../widgets/daily_news_app_bar.dart';
import '../../widgets/daily_news_articles_list.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DailyNewsAppBar(),
      body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
          if (state is RemoteArticlesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is RemoteArticlesError) {
            return const Center(child: Icon(Icons.refresh));
          }
          if (state is RemoteArticlesDone) {
            return DailyNewsArticlesList(articles: state.articles!);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
