import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/core/widgets/grid_background.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comments_section.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_state.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/widgets/user_avatar.dart';

class UserArticleDetailScreen extends StatelessWidget {
  final UserArticleEntity article;
  const UserArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<SessionCubit, String?>((cubit) {
      final state = cubit.state;
      return state is SessionAuthenticated ? state.user.uid : null;
    });
    final isMine = currentUserId == article.authorId;

    return Scaffold(
      body: GridBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: isMine
                  ? [
                      Builder(
                        builder: (builderContext) => IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            final updated = await Navigator.pushNamed(
                              builderContext,
                              '/UploadArticle',
                              arguments: article,
                            );
                            if (updated == true && builderContext.mounted) {
                              Navigator.pop(builderContext, true);
                            }
                          },
                        ),
                      ),
                    ]
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: article.thumbnailUrl == null
                    ? Container(color: Colors.grey.shade400)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: article.thumbnailUrl!,
                            fit: BoxFit.cover,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList.list(
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Butler',
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      UserAvatar(
                        photoUrl: article.authorPhotoUrl,
                        name: article.authorName ?? article.authorEmail,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${article.byline} · ${DateFormat.yMMMd().format(article.publishedAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ArticleContentView(raw: article.content),
                  if (article.id != null)
                    CommentsSection(
                      articleId: article.id!,
                      articleAuthorId: article.authorId,
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

class _ArticleContentView extends StatefulWidget {
  final String raw;
  const _ArticleContentView({required this.raw});

  @override
  State<_ArticleContentView> createState() => _ArticleContentViewState();
}

class _ArticleContentViewState extends State<_ArticleContentView> {
  quill.QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = _tryBuildDeltaController(widget.raw);
  }

  quill.QuillController? _tryBuildDeltaController(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return quill.QuillController(
          document: quill.Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return Text(
        widget.raw,
        style: const TextStyle(fontSize: 15, height: 1.6),
      );
    }
    return quill.QuillEditor.basic(
      controller: c,
      config: const quill.QuillEditorConfig(
        showCursor: false,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
