import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/action/article_action_cubit.dart';
import '../../bloc/article/action/article_action_state.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../widgets/comments_section.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/status_badge.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final hasFirestoreId = article?.id != null &&
        article!.id!.isNotEmpty &&
        article!.authorId != null;
    final isOwner = currentUserId != null &&
        article?.authorId != null &&
        article!.authorId == currentUserId;

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalArticleBloc>(create: (_) => sl<LocalArticleBloc>()),
        BlocProvider<ArticleActionCubit>(
            create: (_) => sl<ArticleActionCubit>()),
        if (hasFirestoreId)
          BlocProvider<CommentBloc>(
            create: (_) => sl<CommentBloc>()
              ..add(CommentsSubscriptionRequested(article!.id!)),
          ),
      ],
      child: BlocListener<ArticleActionCubit, ArticleActionState>(
        listener: (context, state) {
          if (state is ArticleActionDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.articleDeletedSuccessfully),
              ),
            );
            Navigator.pop(context);
          }
          if (state is ArticleActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: _buildBody(context, currentUserId, hasFirestoreId, isOwner),
          floatingActionButton: _buildBookmarkFab(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String? currentUserId,
      bool hasFirestoreId, bool isOwner) {
    return CustomScrollView(
      slivers: [
        // Hero image + AppBar
        _buildSliverAppBar(context, isOwner),
        // Article content
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildArticleHeader(),
                _buildArticleBody(),
                if (hasFirestoreId)
                  CommentsSection(
                    articleId: article!.id!,
                    currentUserId: currentUserId,
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isOwner) {
    final imageUrl = article?.thumbnailUrl;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Navigator.pop(context),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (isOwner) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              '/EditArticle',
              arguments: article,
            ),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _onDeleteArticle(ctx),
            ),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.6, -0.8),
                      end: Alignment(0.6, 0.8),
                      colors: [Color(0xFF1E3A5F), Color(0xFF2D6A9F)],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.6, -0.8),
                    end: Alignment(0.6, 0.8),
                    colors: [Color(0xFF1E3A5F), Color(0xFF2D6A9F)],
                  ),
                ),
              ),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x40000000), Colors.transparent],
                  stops: [0.0, 0.5],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    final authorName = article?.authorName ?? '';
    final initials = authorName.isNotEmpty
        ? authorName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article?.title ?? '',
            style: AppTypography.serif(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.t1,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          // Status badge (if not published)
          if (article?.status != null && article!.status != 'published') ...[
            StatusBadge(status: article!.status!),
            const SizedBox(height: 12),
          ],
          // Author meta
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTypography.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.t1,
                    ),
                  ),
                  Row(
                    children: [
                      if (article?.publishedAt != null)
                        Text(
                          article!.publishedAt!,
                          style: AppTypography.sans(
                              fontSize: 11, color: AppColors.t3),
                        ),
                      if (article?.readingTimeMinutes != null) ...[
                        Text(' · ',
                            style: AppTypography.sans(
                                fontSize: 11, color: AppColors.t3)),
                        Text(
                          '${article!.readingTimeMinutes} min read',
                          style: AppTypography.sans(
                              fontSize: 11, color: AppColors.t3),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Decorative rule
          Row(
            children: [
              const Expanded(
                  child: Divider(height: 1, color: AppColors.border)),
              Container(
                width: 16,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(
                  child: Divider(height: 1, color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildArticleBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description as italic standfirst
          if (article?.description != null &&
              article!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                article!.description!,
                style: AppTypography.serif(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: AppColors.t2,
                  height: 1.65,
                ),
              ),
            ),
          // Content
          if (article?.content != null && article!.content!.isNotEmpty)
            Text(
              article!.content!,
              style: AppTypography.serif(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.t1,
                height: 1.82,
              ),
            ),
          // End ornament
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '— ◆ —',
                style: AppTypography.serif(
                  fontSize: 18,
                  color: AppColors.t3,
                  letterSpacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkFab() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onBookmark(context),
        backgroundColor: AppColors.red,
        elevation: 4,
        child: const Icon(Icons.bookmark, color: Colors.white),
      ),
    );
  }

  Future<void> _onDeleteArticle(BuildContext context) async {
    final confirmed =
        await DeleteConfirmationDialog.show(context, article: article);
    if (!confirmed) return;
    if (!context.mounted) return;

    final articleId = article?.id;
    if (articleId == null) return;

    context.read<ArticleActionCubit>().deleteArticle(articleId);
  }

  void _onBookmark(BuildContext context) {
    if (article == null) return;
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.articleSavedSuccessfully),
      ),
    );
  }
}
