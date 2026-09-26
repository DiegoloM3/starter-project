import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/presentation/formatters/article_date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/article_comment.dart';
import '../../domain/entities/community_article.dart';
import '../bloc/social_interactions_cubit.dart';
import '../services/article_share_service.dart';

typedef LaunchShareOption = Future<bool> Function(
  Uri url, {
  required LaunchMode mode,
  String? webOnlyWindowName,
});

class CommunityArticleDetailScreen extends StatefulWidget {
  final CommunityArticleEntity article;
  final ArticleShareService? shareService;
  final CopyArticleLink? copyArticleLink;
  final LaunchShareOption? launchShareOption;

  const CommunityArticleDetailScreen({
    super.key,
    required this.article,
    this.shareService,
    this.copyArticleLink,
    this.launchShareOption,
  });

  @override
  State<CommunityArticleDetailScreen> createState() =>
      _CommunityArticleDetailScreenState();
}

class _CommunityArticleDetailScreenState
    extends State<CommunityArticleDetailScreen> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          Builder(
            builder: (shareContext) => IconButton(
              tooltip: 'Share article',
              onPressed: () => _share(shareContext),
              icon: const Icon(Icons.ios_share, color: Colors.black),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(widget.article.title,
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text('${widget.article.author} · ${_date(widget.article)}',
              style: TextStyle(color: Colors.grey.shade700)),
          if (widget.article.urlToImage.isNotEmpty) ...[
            const SizedBox(height: 18),
            Semantics(
              image: true,
              label: 'Article image. The full image is shown without cropping.',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 230,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xFFF7F3FA)),
                    child: CachedNetworkImage(
                      imageUrl: widget.article.urlToImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(widget.article.content,
              style: const TextStyle(fontSize: 17, height: 1.55)),
          const SizedBox(height: 24),
          _socialContent(context),
        ],
      ),
    );
  }

  Widget _socialContent(BuildContext context) {
    final socialCubit = _socialCubitOrNull(context);
    if (socialCubit == null) {
      return const SizedBox.shrink();
    }
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        // The detail route keeps its social cubit alive while the auth route
        // is pushed. Clear the old auth prompt as soon as sign-in succeeds so
        // the composer and like action reflect the new session immediately.
        if (authState is AuthSignedIn) {
          socialCubit.refreshLikeState(userId: authState.user.uid);
        } else if (authState is AuthSignedOut) {
          socialCubit.refreshLikeState();
        }
      },
      child: BlocConsumer<SocialInteractionsCubit, SocialInteractionsState>(
        listener: (context, state) {
          if (state.error != null && !state.requiresAuth) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<SocialInteractionsCubit>().clearError();
          }
        },
        builder: (context, state) {
          final cubit = context.read<SocialInteractionsCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: state.isLiked ? 'Unlike article' : 'Like article',
                    child: TextButton.icon(
                      onPressed: state.likeBusy ? null : cubit.toggleLike,
                      icon: state.likeBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              state.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: state.isLiked
                                  ? const Color(0xFF8A4F8D)
                                  : Colors.black87,
                            ),
                      label: Text('${state.likeCount}'),
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (shareContext) => TextButton.icon(
                      onPressed: () => _share(shareContext),
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              if (state.requiresAuth || !cubit.isSignedIn) _authPrompt(context),
              const SizedBox(height: 8),
              Text(
                'Comments (${state.comments.length})',
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _commentComposer(context, state),
              const SizedBox(height: 8),
              if (state.commentsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.comments.isEmpty)
                Text(
                  'No comments yet. Start the conversation.',
                  style: TextStyle(color: Colors.grey.shade700),
                )
              else
                ...state.comments
                    .map((comment) => _commentTile(context, comment)),
              if (state.error != null && state.requiresAuth)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  SocialInteractionsCubit? _socialCubitOrNull(BuildContext context) {
    try {
      return context.read<SocialInteractionsCubit>();
    } catch (_) {
      return null;
    }
  }

  Widget _authPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(child: Text('Sign in to like and comment.')),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/Auth'),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }

  Widget _commentComposer(
    BuildContext context,
    SocialInteractionsState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _commentController,
          enabled: !state.commentBusy,
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Add a comment…',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: state.commentBusy
                ? null
                : () {
                    final body = _commentController.text;
                    if (body.trim().isEmpty) return;
                    context.read<SocialInteractionsCubit>().addComment(body);
                    _commentController.clear();
                  },
            child: state.commentBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post comment'),
          ),
        ),
      ],
    );
  }

  Widget _commentTile(BuildContext context, ArticleCommentEntity comment) {
    final cubit = context.read<SocialInteractionsCubit>();
    final mine = cubit.isSignedIn && cubit.currentUserId == comment.authorUid;
    final initial = comment.authorName.isEmpty
        ? '?'
        : comment.authorName.substring(0, 1).toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFE1BEDE),
            child: Text(initial, style: const TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.authorName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(comment.body),
                const SizedBox(height: 3),
                Text(
                  _commentDate(comment),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          if (mine)
            IconButton(
              tooltip: 'Delete comment',
              onPressed: () => cubit.deleteComment(comment),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext shareContext) async {
    final link = articleDeepLink(widget.article.id);
    final service = widget.shareService ?? const SharePlusArticleShareService();
    final sharePositionOrigin = _sharePositionOrigin(shareContext);
    try {
      await service.shareArticle(
        title: widget.article.title,
        summary: widget.article.description,
        articleId: widget.article.id,
        sharePositionOrigin: sharePositionOrigin,
      );
    } on ArticleShareUnavailable catch (error) {
      if (!mounted) return;
      await _showShareOptions(error);
    } catch (_) {
      if (!mounted) return;
      if (kIsWeb) {
        await _showShareOptions(
          ArticleShareUnavailable(
            title: widget.article.title,
            link: link,
          ),
        );
        return;
      }
      _showShareMessage('Unable to share article.');
    }
  }

  Future<void> _showShareOptions(ArticleShareUnavailable error) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 4, 24, 4),
                    child: Text(
                      'Share article',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Text('Choose an app or copy the link.'),
                  ),
                  if (isLocalShareLink(error.link))
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Text(
                        'This preview link is only reachable on this device until the app is deployed.',
                      ),
                    ),
                  _shareOptionTile(
                    sheetContext,
                    error,
                    target: ArticleShareTarget.whatsapp,
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                  ),
                  _shareOptionTile(
                    sheetContext,
                    error,
                    target: ArticleShareTarget.telegram,
                    icon: Icons.send_outlined,
                    label: 'Telegram',
                  ),
                  _shareOptionTile(
                    sheetContext,
                    error,
                    target: ArticleShareTarget.email,
                    icon: Icons.email_outlined,
                    label: 'Email',
                  ),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('Copy link'),
                    onTap: () => _copyShareLink(sheetContext, error.link),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shareOptionTile(
    BuildContext sheetContext,
    ArticleShareUnavailable error, {
    required ArticleShareTarget target,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _launchShareOption(sheetContext, error, target, label),
    );
  }

  Future<void> _launchShareOption(
    BuildContext sheetContext,
    ArticleShareUnavailable error,
    ArticleShareTarget target,
    String label,
  ) async {
    Navigator.of(sheetContext).pop();
    final uri = articleShareTargetUri(
      target: target,
      title: error.title,
      link: error.link,
    );
    try {
      final didOpen = await (widget.launchShareOption ?? _launchShareOptionUrl)(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_blank' : null,
      );
      if (!didOpen && mounted) _showShareMessage('Unable to open $label.');
    } catch (_) {
      if (mounted) _showShareMessage('Unable to open $label.');
    }
  }

  Future<void> _copyShareLink(BuildContext sheetContext, String link) async {
    Navigator.of(sheetContext).pop();
    try {
      await (widget.copyArticleLink ?? copyArticleLinkToClipboard)(link);
      if (mounted) _showShareMessage('Article link copied.');
    } catch (_) {
      if (mounted) _showShareMessage('Unable to copy article link.');
    }
  }

  Future<bool> _launchShareOptionUrl(
    Uri url, {
    required LaunchMode mode,
    String? webOnlyWindowName,
  }) {
    return launchUrl(
      url,
      mode: mode,
      webOnlyWindowName: webOnlyWindowName,
    );
  }

  void _showShareMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Rect? _sharePositionOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final size = renderObject.size;
    if (size.isEmpty) return null;
    return renderObject.localToGlobal(Offset.zero) & size;
  }

  String _date(CommunityArticleEntity value) {
    final publishedDate = formatStandardDate(value.publishedAt);
    if (publishedDate.isNotEmpty) return publishedDate;
    return formatStandardDate(value.createdAt, fallback: 'Published recently');
  }

  String _commentDate(ArticleCommentEntity value) {
    return formatStandardDate(value.createdAt, fallback: 'Just now');
  }
}
