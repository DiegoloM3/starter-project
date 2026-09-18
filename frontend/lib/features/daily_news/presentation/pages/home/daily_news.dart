import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../bloc/article/remote/remote_article_event.dart';

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
        IconButton(
          tooltip: 'Published Articles',
          onPressed: () => _onShowPublishedArticlesViewTapped(context),
          icon: const Icon(Icons.article_outlined, color: Colors.black),
        ),
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
      builder: (context, state) => Scaffold(
        appBar: _buildAppbar(context),
        body: _buildBody(context, state),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onPublishArticleViewTapped(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RemoteArticlesState state) {
    if (state is RemoteArticlesLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (state is RemoteArticlesError) {
      return Center(
        child: TextButton.icon(
          onPressed: () =>
              context.read<RemoteArticlesBloc>().add(const GetArticles()),
          icon: const Icon(Icons.refresh),
          label: const Text('Unable to load news. Retry'),
        ),
      );
    }
    if (state is RemoteArticlesDone) {
      final articles = state.articles!;
      if (articles.isEmpty) {
        return const Center(child: Text('No news available.'));
      }
      return ListView(
        children: [
          for (final article in articles)
            ArticleWidget(
              article: article,
              onArticlePressed: (article) =>
                  _onArticlePressed(context, article),
            ),
        ],
      );
    }
    return const SizedBox();
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onShowPublishedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/PublishedArticles');
  }

  Future<void> _onPublishArticleViewTapped(BuildContext context) async {
    final published = await Navigator.pushNamed(context, '/PublishArticle');
    if (!context.mounted || published != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Article published successfully.')),
      );
  }
}
