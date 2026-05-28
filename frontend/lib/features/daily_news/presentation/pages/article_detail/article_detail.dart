import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
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
import '../../widgets/reading_time_badge.dart';

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
        BlocProvider<LocalArticleBloc>(
          create: (_) => sl<LocalArticleBloc>(),
        ),
        BlocProvider<ArticleActionCubit>(
          create: (_) => sl<ArticleActionCubit>(),
        ),
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
                backgroundColor: const Color(0xFFCE93D8),
                content: Text(
                    AppLocalizations.of(context)!.articleDeletedSuccessfully),
              ),
            );
            Navigator.pop(context);
          }
          if (state is ArticleActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red[400],
                content: Text(state.error.message),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(isOwner: isOwner),
          body: _buildBody(currentUserId, hasFirestoreId),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool isOwner}) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Icons.chevron_left, color: Colors.black),
        ),
      ),
      actions: [
        if (isOwner) ...[
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () => Navigator.pushNamed(
                context,
                '/EditArticle',
                arguments: article,
              ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => _onDeleteArticle(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(String? currentUserId, bool hasFirestoreId) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
          if (hasFirestoreId)
            CommentsSection(
              articleId: article!.id!,
              currentUserId: currentUserId,
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article?.title ?? '',
            style: const TextStyle(
                fontFamily: 'Butler',
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (article?.readingTimeMinutes != null) ...[
                ReadingTimeBadge(minutes: article!.readingTimeMinutes!),
                const SizedBox(width: 12),
                Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.access_time_outlined, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  article?.publishedAt ?? '',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    final imageUrl = article?.thumbnailUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.maxFinite,
        height: 250,
        margin: const EdgeInsets.only(top: 14),
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      );
    }

    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CupertinoActivityIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
      ),
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '${article?.description ?? ''}\n\n${article?.content ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Icons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onDeleteArticle(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    final articleId = article?.id;
    if (articleId == null) return;

    context.read<ArticleActionCubit>().deleteArticle(articleId);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    if (article == null) return;
    BlocProvider.of<LocalArticleBloc>(context)
        .add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(AppLocalizations.of(context)!.articleSavedSuccessfully),
      ),
    );
  }
}
