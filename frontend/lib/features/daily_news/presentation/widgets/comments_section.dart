import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/comment.dart';
import '../bloc/comment/comment_bloc.dart';
import '../bloc/comment/comment_event.dart';
import '../bloc/comment/comment_state.dart';
import 'comment_tile.dart';
import 'skeleton_comment_tile.dart';

class CommentsSection extends HookWidget {
  final String articleId;
  final String? currentUserId;

  const CommentsSection({
    Key? key,
    required this.articleId,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = useTextEditingController();

    return BlocListener<CommentBloc, CommentState>(
      listenWhen: (prev, curr) =>
          curr is CommentsFailure && prev is! CommentsLoading,
      listener: (context, state) {
        if (state is CommentsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error?.message ??
                    AppLocalizations.of(context)!.commentActionFailed,
              ),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section divider
          Container(height: 2, color: AppColors.ink),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.commentsHeader,
                  style: AppTypography.serif(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.t1,
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state is CommentsDone) {
                      final count = state.comments?.length ?? 0;
                      if (count > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$count',
                            style: AppTypography.sans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Comment input
          _buildCommentInput(context, commentController),
          const SizedBox(height: 4),
          // Comments list
          _buildCommentsList(),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'Y',
              style: AppTypography.sans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: controller,
                style: AppTypography.sans(fontSize: 13.5, color: AppColors.t1),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.addCommentHint,
                  hintStyle:
                      AppTypography.sans(fontSize: 13.5, color: AppColors.t3),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: () => _onSendComment(context, controller),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.send, size: 20, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentsLoading) {
          return Column(
            children:
                List.generate(3, (_) => const SkeletonCommentTile()),
          );
        }
        if (state is CommentsFailure) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 36, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.failedToLoadComments,
                    style: AppTypography.serif(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.t1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is CommentsDone) {
          final comments = state.comments ?? [];
          if (comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 36, color: AppColors.t3),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.noCommentsYet,
                      style: AppTypography.serif(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final comment in comments)
                CommentTile(
                  comment: comment,
                  isOwner: currentUserId != null &&
                      comment.authorId == currentUserId,
                  onDelete: currentUserId != null &&
                          comment.authorId == currentUserId
                      ? () => _onDeleteComment(context, comment)
                      : null,
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onSendComment(
    BuildContext context,
    TextEditingController controller,
  ) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(
          CommentAdded(CommentEntity(
            articleId: articleId,
            authorId: currentUserId,
            content: text,
          )),
        );

    controller.clear();
  }

  void _onDeleteComment(BuildContext context, CommentEntity comment) {
    if (comment.id == null) return;
    context.read<CommentBloc>().add(
          CommentDeleted(
            articleId: articleId,
            commentId: comment.id!,
          ),
        );
  }
}
