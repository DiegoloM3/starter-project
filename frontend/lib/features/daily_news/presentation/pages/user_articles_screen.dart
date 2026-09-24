import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_management/article_management_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_management/article_management_state.dart';

class UserArticlesScreen extends StatefulWidget {
  final String userId;

  const UserArticlesScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserArticlesScreen> createState() => _UserArticlesScreenState();
}

class _UserArticlesScreenState extends State<UserArticlesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArticleManagementCubit>().loadUserArticles(
          userId: widget.userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
        elevation: 0,
      ),
      body: BlocBuilder<ArticleManagementCubit, ArticleManagementState>(
        builder: (context, state) {
          if (state is ArticleManagementLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ArticleManagementFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ArticleManagementCubit>().loadUserArticles(
                            userId: widget.userId,
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ArticleManagementSuccess) {
            final articles = state.articles;

            if (articles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text('No articles yet'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      article.title ?? 'Untitled',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          article.description ?? 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: const Text(
                                'Published',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.green.shade100,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(
                            context,
                            article.id?.toString() ?? '',
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String articleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<ArticleManagementCubit>()
                  .deleteArticle(articleId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
