<<<<<<< HEAD
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

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
=======
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/get_all_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/article_upload_cubit.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/community_article_detail_screen.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/create_article_screen.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/my_articles_screen.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/published_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/widgets/article_tile_shimmer.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  late Future<List<ArticleUploadEntity>> _communityFuture;

  @override
  void initState() {
    super.initState();
    _communityFuture = sl<GetAllArticlesUseCase>()();
  }

  void _refreshCommunity() {
    setState(() {
      _communityFuture = sl<GetAllArticlesUseCase>()();
    });
  }

  void _openCompose() async {
    final published = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<ArticleUploadCubit>()..notifyCreationStarted(),
        child: const ComposeSheet(),
      ),
    );
    if (published == true && mounted) {
      _refreshCommunity();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PublishedScreen()),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Daily News'),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyArticlesScreen()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.article_outlined),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/SavedArticles'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark),
>>>>>>> fbce432 (Finish PR (project setup))
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
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
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
=======
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        final Widget body;
        if (state is RemoteArticlesLoading) {
          body = _buildShimmerList();
        } else if (state is RemoteArticlesDone) {
          body = _buildNewsFeed(state.articles);
        } else {
          body = _buildCommunityFeed();
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: body,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            onPressed: _openCompose,
            child: const Icon(Icons.add),
          ),
        );
>>>>>>> fbce432 (Finish PR (project setup))
      },
    );
  }

<<<<<<< HEAD
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
      body: ListView(
        children: articleWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: REPLACE ROUTE WITH YOUR "ADD ARTICLE" PAGE
        },
        child: const Icon(Icons.add),
=======
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => const ArticleTileShimmer(),
    );
  }

  Widget _buildNewsFeed(List<ArticleEntity> articles) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleWidget(
        article: articles[index],
        onArticlePressed: (article) =>
            Navigator.pushNamed(context, '/ArticleDetails', arguments: article),
>>>>>>> fbce432 (Finish PR (project setup))
      ),
    );
  }

<<<<<<< HEAD
  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
=======
  Widget _buildCommunityFeed() {
    return FutureBuilder<List<ArticleUploadEntity>>(
      future: _communityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const ArticleTileShimmer(),
          );
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article_outlined, size: 48, color: AppColors.textMuted),
                SizedBox(height: 12),
                Text(
                  'No community articles yet.\nBe the first to publish!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: articles.length,
          itemBuilder: (context, index) =>
              _CommunityArticleTile(article: articles[index]),
        );
      },
    );
  }
}

class _CommunityArticleTile extends StatelessWidget {
  final ArticleUploadEntity article;

  const _CommunityArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final preview = article.content.length > 80
        ? '${article.content.substring(0, 80).trim()}...'
        : article.content;
    final dateStr = _formatDate(article.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityArticleDetailScreen(article: article),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: SizedBox(
          height: MediaQuery.of(context).size.width / 2.2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  article.thumbnailUrl,
                  width: MediaQuery.of(context).size.width / 3,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: double.infinity,
                    color: AppColors.accentLight,
                    child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Butler',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timeline_outlined,
                              size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final mo = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final mi = date.minute.toString().padLeft(2, '0');
    return '${y}-${mo}-${d}T${h}:${mi}:00Z';
>>>>>>> fbce432 (Finish PR (project setup))
  }
}
