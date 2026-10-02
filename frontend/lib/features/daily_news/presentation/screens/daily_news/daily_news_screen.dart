import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../../config/theme/app_skeletons.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/article_placeholders.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Placeholder articles drawn as a skeleton while the real ones are loading.
final List<ArticleEntity> _loadingArticles = buildPlaceholderArticles(5);

/// The news from NewsAPI: the "Daily News" tab of the Home section, which the app navigation builds.
class DailyNewsScreen extends StatelessWidget {
  const DailyNewsScreen({super.key});

  @override
  Widget build(BuildContext context) => _buildDailyNewsTab();

  Widget _buildDailyNewsTab() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return AppSkeletonizer(child: _buildArticlesList(context, _loadingArticles));
        }
        if (state is RemoteArticlesError) {
          return const Center(child: Icon(Icons.refresh));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesList(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    // The bottom padding keeps the last article above the translucent navigation bar.
    return ListView.builder(
      padding: EdgeInsets.only(top: 8, bottom: MediaQuery.paddingOf(context).bottom + 8),
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleTile(
        article: articles[index],
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, RouteNames.articleDetails, arguments: article);
  }
}
