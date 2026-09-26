import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/community_article.dart';
import '../bloc/community_feed_cubit.dart';
import '../widgets/community_article_tile.dart';

class CommunityArticlesScreen extends StatelessWidget {
  final void Function(CommunityArticleEntity article) onArticlePressed;

  const CommunityArticlesScreen({
    super.key,
    required this.onArticlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityFeedCubit, CommunityFeedState>(
      builder: (context, state) {
        if (state is CommunityFeedLoading || state is CommunityFeedInitial) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is CommunityFeedFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.read<CommunityFeedCubit>().load(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final articles = (state as CommunityFeedLoaded).articles;
        if (articles.isEmpty) {
          return const Center(
            child: Text('No community articles yet. Be the first to publish.'),
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<CommunityFeedCubit>().load,
          child: ListView.separated(
            itemCount: articles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => CommunityArticleTile(
              article: articles[index],
              onTap: () => onArticlePressed(articles[index]),
            ),
          ),
        );
      },
    );
  }
}
