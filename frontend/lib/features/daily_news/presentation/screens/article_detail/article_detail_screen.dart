import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/theme/app_skeletons.dart';
import '../../../../../config/theme/app_themes.dart';
import '../../../../../config/theme/app_toasts.dart';
import '../../../../../config/theme/bookmark_button.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/bookmark/article_bookmark_cubit.dart';
import '../../bloc/article/bookmark/article_bookmark_state.dart';
import '../../widgets/article_tile.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar adds the platform's back button, with its tooltip and semantics.
      appBar: AppBar(actions: [_buildBookmark(), const SizedBox(width: 4)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildArticleTitleAndDate(),
            _buildArticleImage(context.palette),
            _buildArticleDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmark() {
    return BlocConsumer<ArticleBookmarkCubit, ArticleBookmarkState>(
      listener: _onBookmarkChanged,
      listenWhen: (previous, current) => current is ArticleBookmarkChanged,
      builder: (context, state) => BookmarkButton(
        isSaved: state.isSaved,
        onPressed: state is ArticleBookmarkInProgress ? null : context.read<ArticleBookmarkCubit>().toggleBookmark,
      ),
    );
  }

  void _onBookmarkChanged(BuildContext context, ArticleBookmarkState state) {
    final toast = state.isSaved
        ? const AppToast.success('Article saved', description: 'Find it in Saved.')
        : const AppToast.info('Removed from saved');
    showAppToast(context, toast);
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          ArticlePublicationDate(publishedAt: article.publishedAt),
        ],
      ),
    );
  }

  /// Without an image URL nothing is downloaded: the space keeps the color of an image placeholder.
  Widget _buildArticleImage(AppPalette palette) {
    final imageUrl = article.urlToImage ?? '';
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      color: palette.imagePlaceholder,
      child: imageUrl.isEmpty
          ? null
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ImageLoadingSkeleton(),
              errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: palette.icon),
            ),
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '${article.description ?? ''}\n\n${article.content ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
