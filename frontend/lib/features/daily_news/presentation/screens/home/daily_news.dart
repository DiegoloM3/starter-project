import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/news_category.dart';
import '../../widgets/feed_states.dart';
import '../../widgets/news_article_card.dart';

/// The front door: world news, readable with no account.
///
/// The first article is given the lead treatment and the rest are compact
/// rows, so the feed has a shape instead of being a wall of equal cards.
class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        toolbarHeight: 72,
        title: Text(
          AppLocalizations.of(context).dailyNewsTitle,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: Column(
        children: [
          const _CategoryFilter(),
          Expanded(child: _buildFeed(context)),
        ],
      ),
    );
  }

  Widget _buildFeed(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const FeedLoadingList();
        }
        if (state is RemoteArticlesError) {
          return FeedErrorMessage(
            message: AppLocalizations.of(context).newsLoadFailed,
            onRetry: () => context
                .read<RemoteArticlesBloc>()
                .add(GetArticles(category: state.category)),
          );
        }
        if (state is RemoteArticlesDone) {
          final articles = state.articles ?? const <ArticleEntity>[];

          if (articles.isEmpty) {
            return FeedEmptyMessage(
              icon: Icons.newspaper_outlined,
              title: AppLocalizations.of(context).newsEmptyTitle,
              message: AppLocalizations.of(context).newsEmptyMessage,
            );
          }

          return _NewsList(articles: articles, category: state.category);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// The sections of the paper.
///
/// The News API takes a category per request and returns none on an article,
/// so this is a filter on what is asked for rather than on what came back.
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      buildWhen: (previous, current) => previous.category != current.category,
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: NewsCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = NewsCategory.values[index];

              return _CategoryChip(
                category: category,
                selected: category == state.category,
              );
            },
          ),
        );
      },
    );
  }
}

/// One section of the filter.
///
/// This is a widget rather than a few lines inside the list's `itemBuilder`
/// on purpose. The context an `itemBuilder` is handed belongs to the sliver,
/// not to the item, so a `Theme.of` call made there reads a theme the list
/// does not rebuild on: flipping the device to dark mode left these labels
/// painted in the light theme's near black, invisible on the dark chip.
/// Reading the theme from the chip's own element is what keeps them legible.
class _CategoryChip extends StatelessWidget {
  final NewsCategory category;
  final bool selected;

  const _CategoryChip({required this.category, required this.selected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(_labelOf(AppLocalizations.of(context), category)),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.accent,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : null,
          ),
      onSelected: (_) => context
          .read<RemoteArticlesBloc>()
          .add(GetArticles(category: category)),
    );
  }

  static String _labelOf(AppLocalizations l10n, NewsCategory category) {
    switch (category) {
      case NewsCategory.general:
        return l10n.categoryGeneral;
      case NewsCategory.business:
        return l10n.categoryBusiness;
      case NewsCategory.technology:
        return l10n.categoryTechnology;
      case NewsCategory.science:
        return l10n.categoryScience;
      case NewsCategory.health:
        return l10n.categoryHealth;
      case NewsCategory.sports:
        return l10n.categorySports;
      case NewsCategory.entertainment:
        return l10n.categoryEntertainment;
    }
  }
}

class _NewsList extends StatelessWidget {
  final List<ArticleEntity> articles;
  final NewsCategory category;

  const _NewsList({required this.articles, required this.category});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context
          .read<RemoteArticlesBloc>()
          .add(GetArticles(category: category)),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          // Room for the floating "Write" button to sit over the list without
          // ever covering the last article.
          AppSpacing.huge * 2,
        ),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final article = articles[index];

          if (index == 0) {
            return LeadArticleCard(
              article: article,
              onTap: () => _openArticle(context, article),
            );
          }

          return CompactArticleCard(
            article: article,
            onTap: () => _openArticle(context, article),
          );
        },
      ),
    );
  }

  void _openArticle(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
