import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_bloc.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comment_composer.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comment_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Reusable comments section for an article, owning its [CommentsBloc].
class CommentsSection extends StatelessWidget {
  final String articleId;

  const CommentsSection({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CommentsBloc>()..add(LoadComments(articleId)),
      child: _CommentsView(articleId: articleId),
    );
  }
}

class _CommentsView extends StatefulWidget {
  final String articleId;

  const _CommentsView({required this.articleId});

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final _composerController = TextEditingController();
  bool _postInFlight = false;

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsBloc, CommentsState>(
      listener: _onStateChanged,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) => _buildList(context, state),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) => _buildComposer(context, state),
            ),
            // FAB clearance: the detail page's bookmark button floats at
            // the bottom-right (56px button + 16px margin), so the section
            // reserves that space or it would cover the composer/login row
            // when scrolled to the end.
            const SizedBox(
              key: ValueKey('commentsFabClearance'),
              height: 72,
            ),
          ],
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, CommentsState state) {
    if (state is CommentsError) {
      _postInFlight = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(state.message),
        ),
      );
      context.read<CommentsBloc>().add(LoadComments(widget.articleId));
    } else if (state is CommentsLoaded && _postInFlight) {
      _postInFlight = false;
      _composerController.clear();
    }
  }

  Widget _buildList(BuildContext context, CommentsState state) {
    if (state is CommentsLoading || state is CommentsInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is! CommentsLoaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(state.comments.length),
        if (state.comments.isEmpty) _buildEmpty(),
        for (final comment in state.comments)
          CommentTile(
            comment: comment,
            isOwn: _isOwn(state.currentUserId, comment.authorId),
            onDelete: () => _onDelete(context, comment.id),
          ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Text(
      'Comments ($count)',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No comments yet. Be the first to share your thoughts.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }

  Widget _buildComposer(BuildContext context, CommentsState state) {
    final userId =
        state is CommentsLoaded ? state.currentUserId : null;
    final isLoaded = state is CommentsLoaded;

    if (isLoaded && userId == null) return _buildLoginPrompt(context);

    return CommentComposer(
      controller: _composerController,
      isPosting: _postInFlight,
      onPost: (text) => _onPost(context, text),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Log in to join the discussion.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/Login'),
          child: const Text('Log in'),
        ),
      ],
    );
  }

  bool _isOwn(String? currentUserId, String authorId) {
    return currentUserId != null && currentUserId == authorId;
  }

  void _onPost(BuildContext context, String text) {
    if (text.trim().isEmpty || _postInFlight) return;
    setState(() => _postInFlight = true);
    context.read<CommentsBloc>().add(
          PostCommentRequested(
            articleId: widget.articleId,
            content: text,
          ),
        );
  }

  void _onDelete(BuildContext context, String? commentId) {
    final id = commentId?.trim() ?? '';
    if (id.isEmpty) return;
    context.read<CommentsBloc>().add(
          DeleteCommentRequested(
            articleId: widget.articleId,
            commentId: id,
          ),
        );
  }
}
