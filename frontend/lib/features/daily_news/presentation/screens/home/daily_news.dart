import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/published_articles_list.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  static const int _communityTabIndex = 1;

  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildAppbar(context),
          body: TabBarView(
            children: [
              _buildTopNews(),
              PublishedArticlesList(
                onArticlePressed: (article) => _onPublishedArticlePressed(context, article),
                onPublishPressed: () => _onPublishArticlePressed(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: context.l10n.publishAnArticle,
            onPressed: () => _onPublishArticlePressed(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text('Daily News'),
      actions: [
        IconButton(
          tooltip: context.l10n.savedArticles,
          onPressed: () => _onShowSavedArticlesViewTapped(context),
          icon: const Icon(Icons.bookmark),
        ),
      ],
      bottom: TabBar(
        tabs: [
          Tab(icon: const Icon(Icons.public), text: context.l10n.topNewsTab),
          Tab(icon: const Icon(Icons.edit_note), text: context.l10n.communityTab),
        ],
      ),
    );
  }

  Widget _buildTopNews() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is RemoteArticlesError) {
          return Center(
            child: IconButton(
              tooltip: context.l10n.tryAgain,
              iconSize: 36,
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<RemoteArticlesBloc>().add(const GetArticles()),
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesList(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleWidget(
        article: articles[index],
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onPublishedArticlePressed(BuildContext context, PublishedArticleEntity article) {
    Navigator.pushNamed(context, AppRoutes.publishedArticleDetails, arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  Future<void> _onPublishArticlePressed(BuildContext context) async {
    final published = await Navigator.pushNamed(context, AppRoutes.publishArticle);
    if (published != true || !context.mounted) return;
    DefaultTabController.of(context).animateTo(_communityTabIndex);
    context.read<PublishedArticlesCubit>().loadArticles();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.articlePublished)),
    );
  }
}
