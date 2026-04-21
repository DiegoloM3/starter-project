import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/widgets/user_article_tile.dart';

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: _FilterBar(),
        ),
      ),
      body: BlocBuilder<MyArticlesCubit, MyArticlesState>(
        builder: (context, state) {
          return switch (state) {
            MyArticlesInitial() ||
            MyArticlesLoading() =>
              const Center(child: CircularProgressIndicator()),
            MyArticlesFailure(:final message) => _ErrorView(
                message: message,
                onRetry: () =>
                    context.read<MyArticlesCubit>().load(state.filter),
              ),
            MyArticlesLoaded(:final articles, :final filter) => articles.isEmpty
                ? _EmptyView(filter: filter)
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<MyArticlesCubit>().load(filter),
                    child: ListView.separated(
                      itemCount: articles.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final article = articles[i];
                        return UserArticleTile(
                          article: article,
                          onTap: () async {
                            final changed = await Navigator.pushNamed(
                              context,
                              '/UserArticleDetails',
                              arguments: article,
                            );
                            if (changed == true && context.mounted) {
                              context.read<MyArticlesCubit>().load(filter);
                            }
                          },
                          onDelete: filter == ArticlesFilter.mine
                              ? () => _confirmDelete(context, article.id!)
                              : null,
                        );
                      },
                    ),
                  ),
          };
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String articleId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete article?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<MyArticlesCubit>().deleteArticle(articleId);
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SegmentedButton<ArticlesFilter>(
            segments: const [
              ButtonSegment(
                value: ArticlesFilter.mine,
                label: Text('Mine'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment(
                value: ArticlesFilter.all,
                label: Text('Community'),
                icon: Icon(Icons.groups),
              ),
            ],
            selected: {state.filter},
            onSelectionChanged: (s) =>
                context.read<MyArticlesCubit>().load(s.first),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  final ArticlesFilter filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        filter == ArticlesFilter.mine
            ? 'You have not published any articles yet.'
            : 'No community articles yet.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
