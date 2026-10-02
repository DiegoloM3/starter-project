import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/load_failure_message.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/journalist_article_tile.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/journalist_article_placeholders.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Placeholder articles drawn as a skeleton while the real ones are loading.
final List<JournalistArticleEntity> _loadingArticles = buildPlaceholderJournalistArticles(4);

/// List of the articles published by journalists, shown inside a tab of the home screen.
class PublishedArticlesScreen extends StatelessWidget {
  const PublishedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishedArticlesCubit, PublishedArticlesState>(
      builder: (context, state) {
        if (state is PublishedArticlesSuccess) return _buildArticles(context, state.articles);
        if (state is PublishedArticlesFailure) return _buildFailure(context);
        return AppSkeletonizer(child: _buildArticles(context, _loadingArticles));
      },
    );
  }

  Widget _buildArticles(BuildContext context, List<JournalistArticleEntity> articles) {
    return RefreshIndicator(
      onRefresh: () => context.read<PublishedArticlesCubit>().loadArticles(),
      child: articles.isEmpty
          ? ListView(children: const [_EmptyArticlesMessage()])
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) => JournalistArticleTile(
                article: articles[index],
                onPressed: (article) => _onArticlePressed(context, article),
              ),
            ),
    );
  }

  Widget _buildFailure(BuildContext context) {
    return Center(
      child: LoadFailureMessage(
        message: 'The articles could not be loaded.',
        onRetry: () => context.read<PublishedArticlesCubit>().loadArticles(),
      ),
    );
  }

  /// When the journalist comes back, the articles are read again, so their comment counts are up to date.
  Future<void> _onArticlePressed(BuildContext context, JournalistArticleEntity article) async {
    await Navigator.pushNamed(context, RouteNames.journalistArticleDetails, arguments: article);
    if (context.mounted) context.read<PublishedArticlesCubit>().loadArticles();
  }
}

class _EmptyArticlesMessage extends StatelessWidget {
  const _EmptyArticlesMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No journalist has published an article yet. Tap + to write the first one!',
        textAlign: TextAlign.center,
      ),
    );
  }
}
