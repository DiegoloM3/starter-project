import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/publishable_article.dart';
import '../cubit/published_articles_cubit.dart';
import '../cubit/published_articles_state.dart';
import '../widgets/published_article_tile.dart';

class PublishedArticlesPage extends StatelessWidget {
  const PublishedArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Published Articles',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: BlocBuilder<PublishedArticlesCubit, PublishedArticlesState>(
        builder: (context, state) {
          if (state.isLoading ||
              state.status == PublishedArticlesStatus.initial) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state.isFailure) {
            return _PublishedArticlesMessage(
              icon: Icons.cloud_off_outlined,
              message:
                  state.failureMessage ?? 'Unable to load published articles.',
              actionLabel: 'Retry',
              onAction: context.read<PublishedArticlesCubit>().load,
            );
          }
          if (state.articles.isEmpty) {
            return const _PublishedArticlesMessage(
              icon: Icons.article_outlined,
              message: 'No published articles yet.',
            );
          }
          return ListView.builder(
            itemCount: state.articles.length,
            itemBuilder: (context, index) {
              final article = state.articles[index];
              return PublishedArticleTile(
                article: article,
                onTap: () => _openDetails(context, article),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, PublishableArticle article) {
    Navigator.pushNamed(
      context,
      '/PublishedArticleDetails',
      arguments: article,
    );
  }
}

class _PublishedArticlesMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PublishedArticlesMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
