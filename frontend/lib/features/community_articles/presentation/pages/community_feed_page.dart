import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_state.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<CommunityFeedCubit, CommunityFeedState>(
        builder: (context, state) {
          if (state is CommunityFeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CommunityFeedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load community articles.\n\n${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is CommunityFeedLoaded) {
            if (state.articles.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Be the first to publish — tap the + button below.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.articles.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return ListTile(
                  title: Text(article.title ?? '(untitled)'),
                  subtitle: Text(article.description ?? ''),
                  trailing: Text(
                    article.publishedAt?.substring(0, 10) ?? '',
                    style: const TextStyle(fontSize: 11),
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
}
