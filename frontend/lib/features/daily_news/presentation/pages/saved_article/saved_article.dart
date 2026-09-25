import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/story_tiles.dart';

class SavedArticles extends StatelessWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    // LocalArticleBloc is provided once, app-wide (see main.dart) -- not
    // created here -- so a save/remove from the article detail screen shows
    // up in this list immediately instead of only after this tab remounts.
    return BlocListener<AccountCubit, AccountState>(
      // Saved articles are scoped per signed-in user (see
      // ArticleRepositoryImpl) -- switching accounts, or signing out, means
      // this list has to be reloaded from that new owner's own rows,
      // exactly like UserArticlesFeedScreen already does for its own feed.
      listenWhen: (previous, current) =>
          previous.account?.id != current.account?.id,
      listener: (context, _) =>
          context.read<LocalArticleBloc>().add(const GetSavedArticles()),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      // No back button: this screen is a tab on the floating bar (see
      // MainShell), not a pushed route, so there's nothing to pop back to.
      appBar: AppBar(title: Text(context.l10n.savedArticlesTitle)),
      body: BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: (context, state) {
          if (state is LocalArticlesDone) {
            return _buildArticlesList(context, state.articles!);
          }
          return const Center(child: CupertinoActivityIndicator());
        },
      ),
    );
  }

  Widget _buildArticlesList(
      BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) return const _EmptySaved();
    // Each row's bookmark removes it from here, same as anywhere else.
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, index) => StoryRow(
        article: articles[index],
        onTap: () => Navigator.pushNamed(context, '/ArticleDetails',
            arguments: articles[index]),
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_outline,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(context.l10n.savedEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(context.l10n.savedEmptyDetail,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
