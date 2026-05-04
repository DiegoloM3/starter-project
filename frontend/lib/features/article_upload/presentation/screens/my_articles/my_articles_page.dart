import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MyArticlesPage extends StatefulWidget {
  final String userId;

  const MyArticlesPage({super.key, required this.userId});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MyArticlesBloc>().add(LoadMyArticlesEvent(widget.userId));
    context.read<MyArticlesBloc>().add(const LoadDraftsEvent());
  }

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<MyArticlesBloc>();
    bloc.add(LoadMyArticlesEvent(widget.userId));
    bloc.add(const LoadDraftsEvent());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).myArticlesTitle)),
      body: BlocBuilder<MyArticlesBloc, MyArticlesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.drafts.isEmpty && state.articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No articles yet. Tap + on the home feed to publish your first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _onRefresh(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              if (state.drafts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Drafts',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final draft = state.drafts[index];
                      return _DraftTile(
                        draft: draft,
                        onDelete: () => _confirmDeleteDraft(context, draft),
                        onTap: () =>
                            context.push('/article/upload?draftId=${draft.id}'),
                      );
                    },
                    childCount: state.drafts.length,
                  ),
                ),
              ],
              if (state.articles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Published',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = state.articles[index];
                      final isPending =
                          state.pendingDeletes.contains(article.id);
                      return _ArticleTile(
                        article: article,
                        isPending: isPending,
                        onDelete: () => _confirmDelete(context, article),
                      );
                    },
                    childCount: state.articles.length,
                  ),
                ),
              ],
            ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    JournalistArticleEntity article,
  ) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteArticleTitle),
        content: Text(t.deleteArticleConfirm(article.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<MyArticlesBloc>()
          .add(DeleteArticleRequestedEvent(article.id));
    }
  }

  Future<void> _confirmDeleteDraft(
    BuildContext context,
    DraftArticleEntity draft,
  ) async {
    final t = AppLocalizations.of(context);
    final draftTitle = draft.title.isEmpty ? 'Untitled draft' : draft.title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteDraftTitle),
        content: Text(t.deleteArticleConfirm(draftTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<MyArticlesBloc>()
          .add(DeleteDraftRequestedEvent(draft.id));
    }
  }
}

class _ArticleTile extends StatelessWidget {
  final JournalistArticleEntity article;
  final bool isPending;
  final VoidCallback onDelete;

  const _ArticleTile({
    required this.article,
    required this.isPending,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article.title),
      subtitle: Text(article.description,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isPending
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
      onTap: () => context.push('/article/edit/${article.id}'),
    );
  }
}

class _DraftTile extends StatelessWidget {
  final DraftArticleEntity draft;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _DraftTile({
    required this.draft,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = draft.description.isNotEmpty
        ? draft.description
        : 'Untitled draft';
    return ListTile(
      leading: Chip(label: Text(AppLocalizations.of(context).draftBadge)),
      title: Text(draft.title.isNotEmpty ? draft.title : 'Untitled draft'),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
