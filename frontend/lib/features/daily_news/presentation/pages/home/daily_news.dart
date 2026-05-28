import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/skeleton_article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishedArticlesBloc, PublishedArticlesState>(
      builder: (context, state) {
        if (state is PublishedArticlesLoading) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const SkeletonArticleTile(),
            ),
          );
        }
        if (state is PublishedArticlesFailure) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    state.error?.message ??
                        AppLocalizations.of(context)!.loadArticlesFailed,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.tapToRetry,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFab(context),
          );
        }
        if (state is PublishedArticlesDone) {
          return _buildArticlesPage(context, state.articles ?? []);
        }
        return const SizedBox();
      },
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.appTitle,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/Search'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/Drafts'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.drafts_outlined, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/MyArticles'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () => context
              .read<AuthBloc>()
              .add(const AuthSignOutRequested()),
        ),
      ],
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: articles.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.noArticlesYet,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticleWidget(
                  article: articles[index],
                  onArticlePressed: (article) =>
                      _onArticlePressed(context, article),
                );
              },
            ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
      backgroundColor: const Color(0xFFCE93D8),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
