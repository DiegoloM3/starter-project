import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            AppLocalizations.of(context)!.commentsHeader,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildCommentInput(context, commentController),
        const SizedBox(height: 12),
        _buildCommentsList(),
      ],
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
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addCommentHint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _onSendComment(context, controller),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFCE93D8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send,
                size: 20,
                color: Colors.white,
              ),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: List.generate(
                  3, (_) => const SkeletonCommentTile()),
            ),
          );
        }
        if (state is CommentsFailure) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                state.error?.message ??
                    AppLocalizations.of(context)!.failedToLoadComments,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          );
        }
        if (state is CommentsDone) {
          final comments = state.comments ?? [];
          if (comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noCommentsYet,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final isOwner =
                  currentUserId != null &&
                  comment.authorId == currentUserId;
              return CommentTile(
                comment: comment,
                isOwner: isOwner,
                onDelete: isOwner
                    ? () => _onDeleteComment(context, comment)
                    : null,
              );
            },
          );
        }
        return const SizedBox();
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
