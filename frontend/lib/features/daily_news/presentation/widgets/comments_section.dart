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
  final String? currentUserName;

  const CommentsSection({
    Key? key,
    required this.articleId,
    this.currentUserId,
    this.currentUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = useTextEditingController();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocListener<CommentBloc, CommentState>(
      listenWhen: (prev, curr) => curr is CommentsActionFailure,
      listener: (context, state) {
        if (state is CommentsActionFailure) {
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
          Container(height: 2, color: cs.onSurface),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.commentsHeader,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppSpacing.sm),
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state is CommentsDone ||
                        state is CommentsActionFailure) {
                      final count = state.comments?.length ?? 0;
                      if (count > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.onSurface,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$count',
                            style: tt.labelSmall?.copyWith(
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
          const SizedBox(height: AppSpacing.xs),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              (currentUserName?.trim().isNotEmpty ?? false)
                  ? currentUserName!.trim()[0].toUpperCase()
                  : '?',
              style: tt.labelSmall?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border.all(color: cs.outline, width: 1.5),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
              child: TextField(
                controller: controller,
                maxLength: 2000,
                buildCounter: (
                  _, {
                  required int currentLength,
                  required bool isFocused,
                  int? maxLength,
                }) =>
                    null,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.addCommentHint,
                  hintStyle: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: cs.outlineVariant,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Send button
          GestureDetector(
            onTap: () => _onSendComment(context, controller),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.send, size: 20, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        if (state is CommentsLoading) {
          return Column(
            children:
                List.generate(3, (_) => const SkeletonCommentTile()),
          );
        }
        if (state is CommentsLoadFailure) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 36, color: cs.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppLocalizations.of(context)!.failedToLoadComments,
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.read<CommentBloc>().add(
                          CommentsSubscriptionRequested(articleId),
                        ),
                    child: Text(
                      AppLocalizations.of(context)!.tryAgain,
                      style: tt.labelLarge?.copyWith(color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is CommentsDone || state is CommentsActionFailure) {
          final comments = state.comments ?? [];
          if (comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl2, horizontal: AppSpacing.xl3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 36, color: cs.outlineVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppLocalizations.of(context)!.noCommentsYet,
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
    // The app is auth-gated, but guard anyway: the rule requires
    // authorId == request.auth.uid, so a null user can never write.
    if (currentUserId == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(
          CommentAdded(CommentEntity(
            articleId: articleId,
            authorId: currentUserId,
            // Stored author label. Matches article authoring fallback
            // (di/article_module.dart) so authors render consistently.
            authorName:
                currentUserName ?? AppLocalizations.of(context)!.unknownAuthor,
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
