import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/community_article_detail_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

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
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return _CommunityArticleCard(
                  article: article,
                  onTap: () => _openDetail(context, article),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openDetail(BuildContext context, ArticleEntity article) {
    final cubit = context.read<CommunityFeedCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CommunityArticleDetailPage(article: article),
        ),
      ),
    );
  }
}

class _CommunityArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const _CommunityArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = article.title ?? '(untitled)';
    final description = article.description ?? '';
    final imageUrl = article.urlToImage;
    final publishedAt = article.publishedAt?.substring(0, 10) ?? '';
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 180,
                color: const Color(0xFFEEEEEE),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFFEEEEEE),
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined,
                    color: Color(0xFF9E9E9E)),
              ),
            )
          else
            Container(
              height: 100,
              color: const Color(0xFFF5F5F5),
              alignment: Alignment.center,
              child: const Icon(Icons.article_outlined,
                  size: 40, color: Color(0xFF9E9E9E)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  publishedAt,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
