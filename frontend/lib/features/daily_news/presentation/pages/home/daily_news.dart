import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/widgets/grid_background.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/widgets/user_article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: GridBackground(child: _buildBody(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final published =
              await Navigator.pushNamed(context, '/UploadArticle');
          if (published == true && context.mounted) {
            context.read<MyArticlesCubit>().load(ArticlesFilter.all);
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Write'),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: const Text(
        'DAILY NEWS',
        style: TextStyle(
          fontFamily: 'Butler',
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'My articles',
          icon: const Icon(Icons.article_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/MyArticles'),
        ),
        if (!kIsWeb)
          IconButton(
            tooltip: 'Saved articles',
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/SavedArticles'),
          ),
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/Profile'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, apiState) {
        return BlocBuilder<MyArticlesCubit, MyArticlesState>(
          builder: (context, userState) {
            if (apiState is RemoteArticlesLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (apiState is RemoteArticlesError) {
              return const Center(child: Icon(Icons.refresh));
            }
            final apiArticles = apiState is RemoteArticlesDone
                ? apiState.articles
                : const <ArticleEntity>[];
            final userArticles = userState is MyArticlesLoaded
                ? userState.articles
                : const <UserArticleEntity>[];

            final items = _mergeFeed(apiArticles, userArticles);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MyArticlesCubit>().load(ArticlesFilter.all);
              },
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => _FeedItemWidget(item: items[i]),
              ),
            );
          },
        );
      },
    );
  }

  List<_FeedItem> _mergeFeed(
    List<ArticleEntity> apiArticles,
    List<UserArticleEntity> userArticles,
  ) {
    final items = <_FeedItem>[
      for (final a in apiArticles) _ApiFeedItem(a),
      for (final a in userArticles) _UserFeedItem(a),
    ];
    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items;
  }
}

sealed class _FeedItem {
  DateTime get publishedAt;
}

class _ApiFeedItem extends _FeedItem {
  final ArticleEntity article;
  _ApiFeedItem(this.article);

  @override
  DateTime get publishedAt =>
      DateTime.tryParse(article.publishedAt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class _UserFeedItem extends _FeedItem {
  final UserArticleEntity article;
  _UserFeedItem(this.article);

  @override
  DateTime get publishedAt => article.publishedAt;
}

class _FeedItemWidget extends StatelessWidget {
  final _FeedItem item;
  const _FeedItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      _ApiFeedItem(:final article) => ArticleWidget(
          article: article,
          onArticlePressed: (a) => Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: a,
          ),
        ),
      _UserFeedItem(:final article) => UserArticleTile(
          article: article,
          onTap: () async {
            final changed = await Navigator.pushNamed(
              context,
              '/UserArticleDetails',
              arguments: article,
            );
            if (changed == true && context.mounted) {
              context.read<MyArticlesCubit>().load(ArticlesFilter.all);
            }
          },
        ),
    };
  }
}
