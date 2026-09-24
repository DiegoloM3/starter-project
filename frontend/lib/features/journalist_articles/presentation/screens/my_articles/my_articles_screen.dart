import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed_states.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/journalist_article.dart';
import '../../bloc/my_articles/my_articles_cubit.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../../widgets/article_failure_text.dart';
import '../../widgets/journalist_article_tile.dart';

/// The journalist's own workspace: everything they have written, drafts
/// included, with every action that applies to each one.
class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        toolbarHeight: 72,
        title: Text(
          AppLocalizations.of(context).myArticlesTitle,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: Column(
        children: [
          const _ArticleSearchField(),
          const _StatusFilterBar(),
          const _FailureBanner(),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const FeedLoadingList(itemCount: 3);
        }
        if (state.status == MyArticlesStatus.failure &&
            state.articles.isEmpty) {
          return FeedErrorMessage(
            message: AppLocalizations.of(context).myArticlesLoadFailed,
            onRetry: () => context.read<MyArticlesCubit>().loadArticles(),
          );
        }
        if (state.isEmpty) {
          return _EmptyList(state: state);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.huge,
          ),
          itemCount: state.articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final article = state.articles[index];

            return JournalistArticleTile(
              article: article,
              onEdit: (article) => _openEditor(context, article),
              onPublish: (article) =>
                  context.read<MyArticlesCubit>().publishArticle(article),
              onDelete: (article) => _confirmDelete(context, article),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    JournalistArticleEntity article,
  ) async {
    final cubit = context.read<MyArticlesCubit>();

    await Navigator.pushNamed(
      context,
      '/ArticleEditor',
      arguments: article.id,
    );

    return cubit.loadArticles();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    JournalistArticleEntity article,
  ) async {
    final cubit = context.read<MyArticlesCubit>();

    // A dialog rather than an undo: unlike un-saving somebody else's article,
    // this destroys work that cannot be recovered.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteArticleTitle),
        content: Text(
          AppLocalizations.of(context).deleteArticleMessage(article.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return cubit.deleteArticle(article.id!);
    }
  }
}

/// What the last publish or delete refused to do.
///
/// It used to be a snack bar, which said its piece at the bottom of the screen
/// for four seconds and then took it back — while the row that had failed sat
/// there looking untouched. A banner above the list stays until the next
/// attempt clears it.
class _FailureBanner extends StatelessWidget {
  const _FailureBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      buildWhen: (previous, current) => previous.error != current.error,
      builder: (context, state) {
        if (state.error == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: AlertBanner(
            ArticleFailureText.messageFor(
              AppLocalizations.of(context),
              state.error,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyList extends StatelessWidget {
  final MyArticlesState state;

  const _EmptyList({required this.state});

  @override
  Widget build(BuildContext context) {
    // Told apart on purpose: a filter that matches nothing is not the same as
    // never having written anything, and only one of them needs an invitation.
    final isFiltered =
        state.searchQuery.isNotEmpty || state.statusFilter != null;

    final l10n = AppLocalizations.of(context);

    if (isFiltered) {
      return FeedEmptyMessage(
        icon: Icons.search_off,
        title: l10n.noMatchesTitle,
        message: l10n.noMatchesMessage,
      );
    }

    return FeedEmptyMessage(
      icon: Icons.edit_outlined,
      title: l10n.myArticlesEmptyTitle,
      message: l10n.myArticlesEmptyMessage,
      action: FilledButton(
        onPressed: () => Navigator.pushNamed(context, '/ArticleEditor'),
        child: Text(l10n.writeFirstArticle),
      ),
    );
  }
}

class _ArticleSearchField extends StatelessWidget {
  const _ArticleSearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: TextField(
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          hintText: AppLocalizations.of(context).searchMyArticles,
        ),
        onChanged: (query) => context.read<MyArticlesCubit>().search(query),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      buildWhen: (previous, current) =>
          previous.statusFilter != current.statusFilter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              _filterChip(
                context,
                label: AppLocalizations.of(context).filterAll,
                status: null,
                state: state,
              ),
              const SizedBox(width: AppSpacing.sm),
              _filterChip(
                context,
                label: AppLocalizations.of(context).filterDrafts,
                status: ArticleStatus.draft,
                state: state,
              ),
              const SizedBox(width: AppSpacing.sm),
              _filterChip(
                context,
                label: AppLocalizations.of(context).filterPublished,
                status: ArticleStatus.published,
                state: state,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required ArticleStatus? status,
    required MyArticlesState state,
  }) {
    final selected = state.statusFilter == status;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.accent,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : null,
          ),
      onSelected: (_) => context.read<MyArticlesCubit>().filterByStatus(status),
    );
  }
}
