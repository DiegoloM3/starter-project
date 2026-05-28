import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/user/user_articles_bloc.dart';
import '../../bloc/article/user/user_articles_event.dart';
import '../../bloc/article/user/user_articles_state.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/user_article_tile.dart';

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
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildFilterChips(context),
              Expanded(child: _buildArticlesList(context)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.chevron_left, color: Colors.black),
      ),
      title: Text(
        AppLocalizations.of(context)!.myArticles,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = {
      UserArticlesFilter.all: l10n.filterAll,
      UserArticlesFilter.drafts: l10n.filterDrafts,
      UserArticlesFilter.published: l10n.filterPublished,
      UserArticlesFilter.archived: l10n.filterArchived,
    };

    return BlocBuilder<UserArticlesBloc, UserArticlesState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: filters.entries.map((entry) {
              final isSelected = state.filter == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  selectedColor: const Color(0xFFCE93D8),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  onSelected: (_) {
                    context
                        .read<UserArticlesBloc>()
                        .add(UserArticlesFilterChanged(entry.key));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildArticlesList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<UserArticlesBloc, UserArticlesState>(
      listener: (context, state) {
        if (state is UserArticlesFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[400],
              content: Text(state.error?.message ?? l10n.failedToDeleteArticle),
            ),
          );
        }
      },
      listenWhen: (prev, curr) =>
          curr is UserArticlesFailure && prev is! UserArticlesFailure,
      builder: (context, state) {
        if (state is UserArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is UserArticlesFailure && state.articles == null) {
          return const Center(child: Icon(Icons.refresh));
        }
        if (state is UserArticlesDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return Center(
              child: Text(
                l10n.noUserArticles,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return UserArticleTile(
                article: articles[index],
                onArticlePressed: (article) =>
                    _onArticlePressed(context, article),
                onEdit: (article) => _onEditArticle(context, article),
                onDelete: (article) => _onDeleteArticle(context, article),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onEditArticle(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/EditArticle', arguments: article);
  }

  Future<void> _onDeleteArticle(
    BuildContext context,
    ArticleEntity article,
  ) async {
    final confirmed = await DeleteConfirmationDialog.show(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    final articleId = article.id;
    if (articleId == null) return;

    context.read<UserArticlesBloc>().add(UserArticleDeleteRequested(articleId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFCE93D8),
        content: Text(AppLocalizations.of(context)!.articleDeletedSuccessfully),
      ),
    );
  }
}
