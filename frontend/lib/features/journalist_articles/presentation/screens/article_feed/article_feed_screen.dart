import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed_states.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/get_published_articles_params.dart';
import '../../bloc/article_feed/article_feed_cubit.dart';
import '../../bloc/article_feed/article_feed_state.dart';
import '../../widgets/published_article_tile.dart';

/// A feed of published articles.
///
/// The same screen serves the community feed and one journalist's catalogue;
/// what it shows is decided by the [ArticleFeedCubit] provided above it, not
/// here. [title] is the only thing that tells them apart on screen.
class ArticleFeedScreen extends StatelessWidget {
  /// Null means the community feed, which titles itself; a scoped feed is
  /// given the author's name by whoever opened it.
  final String? titleOverride;

  const ArticleFeedScreen({super.key, this.titleOverride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        toolbarHeight: 72,
        title: Text(
          titleOverride ?? AppLocalizations.of(context).communityTitle,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: BlocBuilder<ArticleFeedCubit, ArticleFeedState>(
        builder: (context, state) {
          if (state.status == ArticleFeedStatus.initial || state.isLoading) {
            return const FeedLoadingList();
          }
          if (state.status == ArticleFeedStatus.failure &&
              state.articles.isEmpty) {
            return FeedErrorMessage(
              message: AppLocalizations.of(context).communityLoadFailed,
              onRetry: () => context.read<ArticleFeedCubit>().loadFeed(),
            );
          }
          if (state.isEmpty) {
            return _EmptyFeed(
              onlyRecent: context.read<ArticleFeedCubit>().onlyRecent,
            );
          }

          return _FeedList(state: state);
        },
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  final ArticleFeedState state;

  const _FeedList({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ArticleFeedCubit>().loadFeed(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.huge * 2,
        ),
        itemCount: state.articles.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index >= state.articles.length) {
            return _LoadMoreButton(isLoading: state.isLoadingMore);
          }

          final article = state.articles[index];

          return PublishedArticleTile(
            article: article,
            onTap: () => _openReader(context, article),
          );
        },
      ),
    );
  }

  void _openReader(BuildContext context, JournalistArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleReader', arguments: article);
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;

  const _LoadMoreButton({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () => context.read<ArticleFeedCubit>().loadMore(),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(AppLocalizations.of(context).loadMoreArticles),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final bool onlyRecent;

  const _EmptyFeed({required this.onlyRecent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = GetPublishedArticlesParams.feedWindow.inDays;

    // Says which of the two silences this is. "Nobody has written anything"
    // and "nothing was written this week" are different facts, and telling
    // them apart is the difference between a dead app and a quiet week.
    return FeedEmptyMessage(
      icon: Icons.forum_outlined,
      title:
          onlyRecent ? l10n.communityEmptyRecentTitle : l10n.authorEmptyTitle,
      message: onlyRecent
          ? l10n.communityEmptyRecentMessage(days)
          : l10n.authorEmptyMessage,
    );
  }
}
