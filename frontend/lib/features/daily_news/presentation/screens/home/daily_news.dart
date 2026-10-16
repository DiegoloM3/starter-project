import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/add_article_button.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/feed_error_message.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: FeedErrorMessage(onRetryPressed: () => _onRetryPressed(context)));
        }
        if (state is RemoteArticlesDone || state is RemoteArticlesRefreshing) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    List<Widget> articleWidgets = [];
    for (var article in articles) {
      articleWidgets.add(ArticleWidget(
        article: article,
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ));
    }

    return Scaffold(
      appBar: _buildAppbar(context),
      body: RefreshIndicator(
        onRefresh: () => _refreshArticles(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: articleWidgets,
        ),
      ),
      floatingActionButton: AddArticleButton(
        onPressed: () => _onAddArticlePressed(context),
      ),
    );
  }

  void _onRetryPressed(BuildContext context) {
    BlocProvider.of<RemoteArticlesBloc>(context).add(const GetArticles());
  }

  /// Loads the feed again and completes once the new articles are shown.
  Future<void> _refreshArticles(BuildContext context) async {
    final remoteArticlesBloc = BlocProvider.of<RemoteArticlesBloc>(context);
    remoteArticlesBloc.add(const GetArticles());
    await remoteArticlesBloc.stream.firstWhere((state) => state is! RemoteArticlesRefreshing);
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  Future<void> _onAddArticlePressed(BuildContext context) async {
    final remoteArticlesBloc = BlocProvider.of<RemoteArticlesBloc>(context);
    final isArticlePublished = await Navigator.pushNamed(context, '/PublishArticle');
    if (isArticlePublished == true) {
      remoteArticlesBloc.add(const GetArticles());
    }
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
