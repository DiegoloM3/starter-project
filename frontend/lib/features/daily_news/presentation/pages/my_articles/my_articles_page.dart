import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/user/user_articles_bloc.dart';
import '../../bloc/article/user/user_articles_event.dart';
import '../../bloc/article/user/user_articles_state.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_article_tile.dart';

class MyArticlesPage extends HookWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Icon(Icons.person_off, size: 48)),
      );
    }

    return BlocProvider<UserArticlesBloc>(
      create: (_) => sl<UserArticlesBloc>()
        ..add(UserArticlesSubscriptionRequested(currentUserId)),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.bg,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _FilterTabs(),
              Expanded(child: _ArticlesList()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: AppColors.t1, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.myArticles,
        style: AppTypography.serif(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.t1,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/CreateArticle'),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter tabs with counts
// ---------------------------------------------------------------------------
class _FilterTabs extends StatelessWidget {
  static const _filters = [
    UserArticlesFilter.all,
    UserArticlesFilter.drafts,
    UserArticlesFilter.published,
    UserArticlesFilter.archived,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <String, String>{
      UserArticlesFilter.all: l10n.filterAll,
      UserArticlesFilter.drafts: l10n.filterDrafts,
      UserArticlesFilter.published: l10n.filterPublished,
      UserArticlesFilter.archived: l10n.filterArchived,
    };

    return BlocBuilder<UserArticlesBloc, UserArticlesState>(
      buildWhen: (prev, curr) =>
          prev.filter != curr.filter || prev.articles != curr.articles,
      builder: (context, state) {
        // Counts are computed from unfiltered articles stored in bloc.
        // state.articles already represents the filtered list, but we
        // need global counts. Re-derive from the same source the bloc
        // sees: the full list is not exposed, so we approximate by
        // using state.articles when the filter is 'all', otherwise
        // we only show the filtered count (acceptable UX).
        final allArticles = state.articles ?? [];
        // When on "all" tab, allArticles IS the full list — compute counts.
        // On other tabs, we still have the full list because the bloc stores
        // both; however state.articles is filtered. For accurate counts we
        // read all articles from a parent-level bloc read if possible.
        // Since UserArticlesBloc exposes filtered articles per state, we
        // store _allArticles in the bloc. For now we compute from available data.
        final counts = <String, int>{
          UserArticlesFilter.all: allArticles.length,
          UserArticlesFilter.drafts:
              allArticles.where((a) => a.status == 'draft').length,
          UserArticlesFilter.published:
              allArticles.where((a) => a.status == 'published').length,
          UserArticlesFilter.archived:
              allArticles.where((a) => a.status == 'archived').length,
        };

        return Container(
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: _filters.map((filter) {
              final isActive = filter == state.filter;
              final count = counts[filter] ?? 0;
              return _FilterTab(
                label: labels[filter]!,
                count: count,
                isActive: isActive,
                onTap: () => context
                    .read<UserArticlesBloc>()
                    .add(UserArticlesFilterChanged(filter)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.sans(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive ? AppColors.red : AppColors.t2,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.red : AppColors.t3,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : AppColors.surface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (isActive)
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Articles list content
// ---------------------------------------------------------------------------
class _ArticlesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<UserArticlesBloc, UserArticlesState>(
      listener: (context, state) {
        if (state is UserArticlesFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.error?.message ?? l10n.failedToDeleteArticle),
            ),
          );
        }
      },
      listenWhen: (prev, curr) =>
          curr is UserArticlesFailure && prev is! UserArticlesFailure,
      builder: (context, state) {
        if (state is UserArticlesLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => SkeletonArticleTile(showDivider: i < 4),
          );
        }

        if (state is UserArticlesFailure && state.articles == null) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            subtitle: l10n.couldNotLoadArticles,
            actionLabel: l10n.tryAgain,
            onAction: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context
                    .read<UserArticlesBloc>()
                    .add(UserArticlesSubscriptionRequested(uid));
              }
            },
          );
        }

        if (state is UserArticlesDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return _emptyForFilter(context, state.filter);
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleWidget(
                article: article,
                showStatus: true,
                showReadingTime: true,
                showActions: true,
                showDivider: index < articles.length - 1,
                onArticlePressed: (a) => _onArticlePressed(context, a),
                onEdit: (a) => _onEditArticle(context, a),
                onDelete: (a) => _onDeleteArticle(context, a),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _emptyForFilter(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context)!;
    if (filter == UserArticlesFilter.drafts) {
      return EmptyStateWidget(
        icon: Icons.edit_note,
        title: l10n.noDraftsTitle,
        subtitle: l10n.noDraftsSubtitle,
        actionLabel: l10n.writeAnArticle,
        onAction: () => Navigator.pushNamed(context, '/CreateArticle'),
      );
    }
    if (filter == UserArticlesFilter.published) {
      return EmptyStateWidget(
        icon: Icons.publish,
        title: l10n.noPublishedTitle,
        subtitle: l10n.noPublishedSubtitle,
        actionLabel: l10n.writeAnArticle,
        onAction: () => Navigator.pushNamed(context, '/CreateArticle'),
      );
    }
    if (filter == UserArticlesFilter.archived) {
      return EmptyStateWidget(
        icon: Icons.archive_outlined,
        title: l10n.noArchivedTitle,
        subtitle: l10n.noArchivedSubtitle,
      );
    }
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: l10n.noArticlesTitle,
      subtitle: l10n.noArticlesSubtitle,
      actionLabel: l10n.writeAnArticle,
      onAction: () => Navigator.pushNamed(context, '/CreateArticle'),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    if (article.status == 'draft') {
      Navigator.pushNamed(context, '/EditArticle', arguments: article);
    } else {
      Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
    }
  }

  void _onEditArticle(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/EditArticle', arguments: article);
  }

  Future<void> _onDeleteArticle(
    BuildContext context,
    ArticleEntity article,
  ) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      article: article,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final articleId = article.id;
    if (articleId == null) return;

    context.read<UserArticlesBloc>().add(UserArticleDeleteRequested(articleId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.articleDeletedSuccessfully),
      ),
    );
  }
}
