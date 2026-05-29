import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_status.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/action/article_action_cubit.dart';
import '../../bloc/article/action/article_action_state.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../widgets/comments_section.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/status_badge.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user!.uid : null;
    final currentUserName =
        authState is AuthAuthenticated ? authState.user!.displayName : null;
    // Comments work for any article with a stable id — both Firestore
    // (user-created) and API articles (id is a deterministic md5 of the url).
    final canComment = article?.id != null && article!.id!.isNotEmpty;
    final isOwner = currentUserId != null &&
        article?.authorId != null &&
        article!.authorId == currentUserId;

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalArticleBloc>(create: (_) => sl<LocalArticleBloc>()),
        BlocProvider<ArticleActionCubit>(
            create: (_) => sl<ArticleActionCubit>()),
        if (canComment)
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
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          body: _buildBody(
              context, currentUserId, currentUserName, canComment, isOwner),
          floatingActionButton: _buildBookmarkFab(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String? currentUserId,
      String? currentUserName, bool canComment, bool isOwner) {
    return CustomScrollView(
      slivers: [
        // Hero image + AppBar
        _buildSliverAppBar(context, isOwner),
        // Article content
        SliverToBoxAdapter(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildArticleHeader(context),
                _buildArticleBody(context),
                if (canComment)
                  CommentsSection(
                    articleId: article!.id!,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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

  Widget _buildArticleHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article?.title ?? '',
            style: tt.headlineLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 14),
          // Status badge (if not published)
          if (article?.status != null &&
              article!.status != ArticleStatus.published) ...[
            StatusBadge(status: article!.status!),
            const SizedBox(height: AppSpacing.md),
          ],
          // Author meta
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: tt.labelMedium?.copyWith(
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
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      if (article?.publishedAt != null)
                        Text(
                          article!.publishedAt!,
                          style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: cs.outlineVariant),
                        ),
                      if (article?.readingTimeMinutes != null) ...[
                        Text(' · ',
                            style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: cs.outlineVariant)),
                        Text(
                          l10n.readingTime(article!.readingTimeMinutes!),
                          style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: cs.outlineVariant),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Decorative rule
          Row(
            children: [
              Expanded(child: Divider(height: 1, color: cs.outline)),
              Container(
                width: 16,
                height: 3,
                margin:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              Expanded(child: Divider(height: 1, color: cs.outline)),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildArticleBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description as italic standfirst
          if (article?.description != null &&
              article!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Text(
                article!.description!,
                style: tt.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: cs.onSurfaceVariant,
                  height: 1.65,
                ),
              ),
            ),
          // Content
          if (article?.content != null && article!.content!.isNotEmpty)
            Text(
              article!.content!,
              style: tt.bodyLarge,
            ),
          // End ornament
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '— ◆ —',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.outlineVariant,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    BlocProvider.of<LocalArticleBloc>(context).add(ArticleSaved(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.articleSavedSuccessfully),
      ),
    );
  }
}
