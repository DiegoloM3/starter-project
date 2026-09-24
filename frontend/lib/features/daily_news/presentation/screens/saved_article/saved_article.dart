import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/feed_states.dart';
import '../../widgets/news_article_card.dart';

/// Everything the reader kept for later.
///
/// Compact rows only: this is a list to come back to, not a feed to browse,
/// so nothing here is given the lead treatment the news feed uses.
class SavedArticles extends StatelessWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        toolbarHeight: 72,
        title: Text(
          AppLocalizations.of(context).savedTitle,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: (context, state) {
          if (state is LocalArticlesLoading) {
            return const FeedLoadingList(itemCount: 3);
          }
          if (state is LocalArticlesDone) {
            final articles = state.articles ?? const <ArticleEntity>[];

            if (articles.isEmpty) {
              return FeedEmptyMessage(
                icon: Icons.bookmark_border,
                title: AppLocalizations.of(context).savedEmptyTitle,
                message: AppLocalizations.of(context).savedEmptyMessage,
              );
            }

            return _SavedList(articles: articles);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  final List<ArticleEntity> articles;

  const _SavedList({required this.articles});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.huge,
      ),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final article = articles[index];

        return CompactArticleCard(
          article: article,
          onTap: () => Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: article,
          ),
          trailing: _RemoveButton(
            onPressed: () => _remove(context, article),
          ),
        );
      },
    );
  }

  void _remove(BuildContext context, ArticleEntity article) {
    final bloc = context.read<LocalArticleBloc>();

    bloc.add(RemoveArticle(article));

    // Undo instead of "are you sure?". Removing one saved article is small
    // and easy to do by accident, and an offer to put it back costs the
    // reader nothing, where a confirmation dialog would tax every deliberate
    // removal to catch the rare mistaken one.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).removedFromSaved),
          duration: kUndoDuration,
          // `persist` defaults to `action != null`, so simply offering Undo
          // made this snack bar permanent: Flutter starts the dismissal timer
          // and then returns from it without doing anything. It sat there
          // indefinitely and followed the reader into the other tabs, still
          // offering to put back an article they could no longer see.
          //
          // Undo is a courtesy with a deadline, not a decision being waited
          // on, so it is dismissed on time like any other confirmation. The
          // article is also still in the list, and can be saved again.
          persist: false,
          action: SnackBarAction(
            label: AppLocalizations.of(context).undo,
            onPressed: () => bloc.add(SaveArticle(article)),
          ),
        ),
      );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      // A filled bookmark that un-fills when tapped: the same control that
      // saved the article, in the state that says it is saved. Reachable by
      // tap, never only by a swipe.
      icon: const Icon(Icons.bookmark, color: AppColors.accent),
      tooltip: AppLocalizations.of(context).removeFromSaved,
      iconSize: 22,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
