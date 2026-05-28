import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

import '../../../../../injection_container.dart';

class DraftsPage extends StatelessWidget {
  const DraftsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider<DraftsListBloc>(
      create: (_) =>
          sl<DraftsListBloc>()..add(DraftsSubscriptionRequested(userId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left,
                color: Colors.black, size: 30),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Drafts',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<DraftsListBloc, DraftsListState>(
          builder: (context, state) {
            if (state is DraftsListLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFCE93D8)),
              );
            }

            if (state is DraftsListFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(
                      state.error?.message ?? 'Failed to load drafts',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            if (state is DraftsListDone) {
              final articles = state.articles ?? [];

              if (articles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drafts_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No drafts yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start writing and your drafts will appear here',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Dismissible(
                    key: ValueKey(article.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red[400],
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context),
                    onDismissed: (_) {
                      if (article.id != null) {
                        context
                            .read<DraftsListBloc>()
                            .add(DraftDeleted(article.id!));
                      }
                    },
                    child: ArticleWidget(
                      article: article,
                      showStatus: true,
                      showReadingTime: true,
                      onArticlePressed: (a) {
                        Navigator.pushNamed(
                          context,
                          '/CreateArticle',
                          arguments: a,
                        );
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Draft'),
            content: const Text(
                'Are you sure you want to delete this draft? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400]),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
