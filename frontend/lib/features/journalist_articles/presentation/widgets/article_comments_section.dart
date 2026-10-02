import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/load_failure_message.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_comments/article_comments_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_comments/article_comments_state.dart';

import 'article_comment_card.dart';

/// Placeholder comments drawn as a skeleton while the comments are loading.
final List<ArticleCommentEntity> _loadingComments = List.generate(
  2,
  (index) => ArticleCommentEntity(
    id: 'loading$index',
    content: 'A comment about the article that takes about two lines of the card.',
    author: 'Journalist name',
    authorId: '',
    createdAt: DateTime.utc(2026),
  ),
);

/// "Comments" title with their number, followed by the comments of the article, oldest first.
class ArticleCommentsSection extends StatelessWidget {
  const ArticleCommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<ArticleCommentsCubit, ArticleCommentsState>(
      builder: (context, state) => Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.divider))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CommentsTitle(count: state is ArticleCommentsSuccess ? state.comments.length : null),
            const SizedBox(height: 12),
            _buildContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticleCommentsState state) {
    if (state is ArticleCommentsSuccess) {
      return state.comments.isEmpty ? const _NoCommentsMessage() : _CommentList(comments: state.comments);
    }
    if (state is ArticleCommentsFailure) {
      return LoadFailureMessage(
        message: 'The comments could not be loaded.',
        onRetry: context.read<ArticleCommentsCubit>().loadComments,
      );
    }
    return AppSkeletonizer(child: _CommentList(comments: _loadingComments));
  }
}

class _CommentsTitle extends StatelessWidget {
  /// Unknown while the comments are loading.
  final int? count;

  const _CommentsTitle({required this.count});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final count = this.count;
    return Row(
      children: [
        const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        if (count != null)
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: palette.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: palette.primary),
            ),
          ),
      ],
    );
  }
}

class _CommentList extends StatelessWidget {
  final List<ArticleCommentEntity> comments;

  const _CommentList({required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final comment in comments)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ArticleCommentCard(comment: comment),
          ),
      ],
    );
  }
}

class _NoCommentsMessage extends StatelessWidget {
  const _NoCommentsMessage();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: palette.primarySoft, borderRadius: BorderRadius.circular(16)),
            child: Icon(Ionicons.chatbubbleOutline, size: 24, color: palette.primary),
          ),
          const SizedBox(height: 8),
          const Text('No comments yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Be the first to share what you think.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
