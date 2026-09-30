import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/l10n.dart';
import '../../domain/entities/published_article.dart';
import '../bloc/published_articles/published_articles_cubit.dart';
import '../bloc/published_articles/published_articles_state.dart';
import 'published_article_tile.dart';

/// Articles published by journalists in the app, newest first, with pull-to-refresh and
/// infinite scroll. Expects a [PublishedArticlesCubit] above it.
class PublishedArticlesList extends StatelessWidget {
  final ValueChanged<PublishedArticleEntity> onArticlePressed;
  final VoidCallback onPublishPressed;

  const PublishedArticlesList({super.key, required this.onArticlePressed, required this.onPublishPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishedArticlesCubit, PublishedArticlesState>(
      builder: (context, state) => switch (state) {
        PublishedArticlesLoading() => const Center(child: CupertinoActivityIndicator()),
        PublishedArticlesError() => _MessageView(
            icon: Icons.cloud_off,
            message: context.l10n.articlesCouldNotLoad,
            actionLabel: context.l10n.tryAgain,
            onAction: context.read<PublishedArticlesCubit>().loadArticles,
          ),
        PublishedArticlesLoaded(articles: final articles) when articles.isEmpty => _MessageView(
            icon: Icons.edit_note,
            message: context.l10n.noArticlesYet,
            actionLabel: context.l10n.writeAnArticle,
            onAction: onPublishPressed,
          ),
        PublishedArticlesLoaded() => _ArticlesListView(state: state, onArticlePressed: onArticlePressed),
      },
    );
  }
}

class _ArticlesListView extends StatelessWidget {
  // Start loading the next page this many pixels before reaching the end of the list.
  static const double _loadMoreThreshold = 400;

  final PublishedArticlesLoaded state;
  final ValueChanged<PublishedArticleEntity> onArticlePressed;

  const _ArticlesListView({required this.state, required this.onArticlePressed});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PublishedArticlesCubit>();
    return RefreshIndicator(
      onRefresh: cubit.loadArticles,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _loadMoreNearTheEnd(notification, cubit),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == state.articles.length) {
      return const Padding(padding: EdgeInsets.all(16), child: CupertinoActivityIndicator());
    }
    return PublishedArticleTile(article: state.articles[index], onPressed: onArticlePressed);
  }

  bool _loadMoreNearTheEnd(ScrollNotification notification, PublishedArticlesCubit cubit) {
    if (notification.metrics.extentAfter < _loadMoreThreshold) cubit.loadMoreArticles();
    return false;
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageView({required this.icon, required this.message, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
