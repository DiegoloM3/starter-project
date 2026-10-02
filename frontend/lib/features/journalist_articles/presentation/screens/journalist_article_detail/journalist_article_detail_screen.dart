import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_skeletons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/app_toasts.dart';
import 'package:news_app_clean_architecture/config/theme/bookmark_button.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_comments/article_comments_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/article_comments_section.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/comment_composer.dart';
import 'package:news_app_clean_architecture/config/theme/publication_date_text.dart';

/// An article with its comments, and the pill to write a new one floating above them.
class JournalistArticleDetailScreen extends StatefulWidget {
  static const double _minimumBottomMargin = 12;

  final JournalistArticleEntity article;

  const JournalistArticleDetailScreen({super.key, required this.article});

  @override
  State<JournalistArticleDetailScreen> createState() => _JournalistArticleDetailScreenState();
}

class _JournalistArticleDetailScreenState extends State<JournalistArticleDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  JournalistArticleEntity get _article => widget.article;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Like the navigation bar, the pill rests right on top of the phone's gesture area (or of the keyboard).
    final bottomMargin = math.max(
      MediaQuery.paddingOf(context).bottom,
      JournalistArticleDetailScreen._minimumBottomMargin,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
          icon: const Icon(Ionicons.chevronBack),
        ),
        actions: [_buildBookmark(), const SizedBox(width: 4)],
      ),
      body: BlocListener<AddArticleCommentCubit, AddArticleCommentState>(
        listener: _onCommentStateChanged,
        child: Stack(
          children: [
            _buildArticleWithComments(bottomPadding: CommentComposer.height + bottomMargin + 24),
            Positioned(left: 16, right: 16, bottom: bottomMargin, child: const CommentComposer()),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleWithComments({required double bottomPadding}) {
    return RefreshIndicator(
      onRefresh: context.read<ArticleCommentsCubit>().loadComments,
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: bottomPadding),
        children: [
          _buildHeader(),
          _buildThumbnail(),
          _buildBody(),
          const ArticleCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildBookmark() {
    return BlocConsumer<JournalistArticleBookmarkCubit, JournalistArticleBookmarkState>(
      listenWhen: (previous, current) =>
          current is JournalistArticleBookmarkChanged || current is JournalistArticleBookmarkFailure,
      listener: _onBookmarkChanged,
      builder: (context, state) => BookmarkButton(
        isSaved: state.isSaved,
        onPressed: state is JournalistArticleBookmarkInProgress
            ? null
            : context.read<JournalistArticleBookmarkCubit>().toggleBookmark,
      ),
    );
  }

  void _onBookmarkChanged(BuildContext context, JournalistArticleBookmarkState state) {
    if (state is JournalistArticleBookmarkFailure) {
      showAppToast(
        context,
        const AppToast.error('Your saved articles could not be updated', description: 'Please try again.'),
      );
      return;
    }
    final toast = state.isSaved
        ? const AppToast.success('Article saved', description: 'Find it in Saved, in the Journalists tab.')
        : const AppToast.info('Removed from saved');
    showAppToast(context, toast);
  }

  void _onCommentStateChanged(BuildContext context, AddArticleCommentState state) {
    if (state is AddArticleCommentSuccess) {
      context.read<ArticleCommentsCubit>().showAddedComment(state.comment);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLastComment());
    }
    if (state is AddArticleCommentFailure) {
      showAppToast(
        context,
        const AppToast.error('Your comment could not be sent', description: 'Check your connection and try again.'),
      );
    }
  }

  void _scrollToLastComment() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _article.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text('By ${_article.author}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          PublicationDateText(publishedAt: _article.publishedAt),
        ],
      ),
    );
  }

  /// Without a thumbnail URL nothing is downloaded, as in the article tiles.
  Widget _buildThumbnail() {
    return Container(
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      color: context.palette.imagePlaceholder,
      child: _article.thumbnailURL.isEmpty
          ? null
          : CachedNetworkImage(
              imageUrl: _article.thumbnailURL,
              fit: BoxFit.cover,
              width: double.maxFinite,
              placeholder: (_, __) => const ImageLoadingSkeleton(),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
            ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _article.description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Text(_article.content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
