import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments_state.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_state.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/widgets/user_avatar.dart';

class CommentsSection extends StatefulWidget {
  final String articleId;
  final String articleAuthorId;

  const CommentsSection({
    super.key,
    required this.articleId,
    required this.articleAuthorId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitTopLevel() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final ok = await context.read<CommentsCubit>().submit(widget.articleId, text);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.select<SessionCubit, String?>((cubit) {
      final state = cubit.state;
      return state is SessionAuthenticated ? state.user.uid : null;
    });
    final isOwnArticle = currentUid == widget.articleAuthorId;

    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final counter =
            state is CommentsLoaded ? ' (${state.comments.length})' : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Comments$counter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isOwnArticle)
              _Composer(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: _submitTopLevel,
                submitting: state is CommentsLoaded && state.submitting,
                error: state is CommentsLoaded ? state.submitError : null,
                hint: 'Leave a comment…',
              ),
            if (isOwnArticle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'You can reply to comments on your own article.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            if (state is CommentsLoading)
              const Center(child: CircularProgressIndicator()),
            if (state is CommentsError)
              Text(state.message, style: const TextStyle(color: Colors.red)),
            if (state is CommentsLoaded)
              ..._buildThreadedComments(
                state.comments,
                currentUid: currentUid,
                canReply: isOwnArticle,
                submitting: state.submitting,
                submitError: state.submitError,
              ),
            if (state is CommentsLoaded && state.comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No comments yet.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildThreadedComments(
    List<CommentEntity> all, {
    required String? currentUid,
    required bool canReply,
    required bool submitting,
    required String? submitError,
  }) {
    final topLevel = all.where((c) => c.replyTo == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final repliesByParent = <String, List<CommentEntity>>{};
    for (final c in all) {
      final parent = c.replyTo;
      if (parent == null) continue;
      repliesByParent.putIfAbsent(parent, () => []).add(c);
    }
    for (final list in repliesByParent.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return [
      for (final parent in topLevel)
        _CommentThread(
          parent: parent,
          replies: repliesByParent[parent.id] ?? const [],
          currentUid: currentUid,
          onReply: canReply && !parent.isDeleted
              ? (text) => context.read<CommentsCubit>().submit(
                    widget.articleId,
                    text,
                    replyTo: parent.id,
                  )
              : null,
          onDelete: (commentId) =>
              context.read<CommentsCubit>().delete(widget.articleId, commentId),
          submitting: submitting,
          submitError: submitError,
        ),
    ];
  }
}

class _CommentThread extends StatefulWidget {
  final CommentEntity parent;
  final List<CommentEntity> replies;
  final String? currentUid;
  final Future<bool> Function(String text)? onReply;
  final void Function(String commentId) onDelete;
  final bool submitting;
  final String? submitError;

  const _CommentThread({
    required this.parent,
    required this.replies,
    required this.currentUid,
    required this.onReply,
    required this.onDelete,
    required this.submitting,
    required this.submitError,
  });

  @override
  State<_CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends State<_CommentThread> {
  bool _showReply = false;
  final _replyController = TextEditingController();
  final _replyFocus = FocusNode();

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || widget.onReply == null) return;
    final ok = await widget.onReply!(text);
    if (!mounted) return;
    if (ok) {
      _replyController.clear();
      setState(() => _showReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CommentTile(
          comment: widget.parent,
          onDelete: !widget.parent.isDeleted &&
                  widget.parent.authorId == widget.currentUid
              ? () => widget.onDelete(widget.parent.id!)
              : null,
          onReplyTap: widget.onReply == null
              ? null
              : () => setState(() {
                    _showReply = !_showReply;
                    if (_showReply) _replyFocus.requestFocus();
                  }),
        ),
        if (_showReply)
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 8),
            child: _Composer(
              controller: _replyController,
              focusNode: _replyFocus,
              onSubmit: _submitReply,
              submitting: widget.submitting,
              error: widget.submitError,
              hint: 'Write a reply…',
            ),
          ),
        for (final reply in widget.replies)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _CommentTile(
              comment: reply,
              onDelete: !reply.isDeleted && reply.authorId == widget.currentUid
                  ? () => widget.onDelete(reply.id!)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final bool submitting;
  final String? error;
  final String hint;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.submitting,
    required this.error,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            suffixIcon: submitting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSubmit,
                  ),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback? onDelete;
  final VoidCallback? onReplyTap;

  const _CommentTile({
    required this.comment,
    this.onDelete,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().add_jm().format(comment.createdAt);
    final name = comment.isDeleted
        ? 'Deleted'
        : comment.authorName?.trim().isNotEmpty == true
            ? comment.authorName!
            : 'Unknown';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            photoUrl: comment.isDeleted ? null : comment.authorPhotoUrl,
            name: comment.isDeleted ? null : comment.authorName,
            radius: 14,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.isDeleted ? 'Comment deleted.' : comment.text,
                  style: comment.isDeleted
                      ? TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        )
                      : null,
                ),
                if (onReplyTap != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onReplyTap,
                      icon: const Icon(Icons.reply, size: 14),
                      label: const Text(
                        'Reply',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
