import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../injection_container.dart';
import '../../../../../l10n/l10n.dart';
import '../../../domain/entities/article_narration_progress.dart';
import '../../../domain/entities/published_article.dart';
import '../../bloc/article_narration/article_narration_cubit.dart';
import '../../bloc/article_narration/article_narration_state.dart';
import '../../widgets/follow_along_text.dart';
import '../../widgets/listen_button.dart';
import '../../widgets/published_article_tile.dart';

/// Full article written by a journalist, with its Markdown content rendered.
class PublishedArticleDetailView extends StatelessWidget {
  final PublishedArticleEntity article;

  const PublishedArticleDetailView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticleNarrationCubit>(),
      child: PublishedArticleDetail(article: article),
    );
  }
}

/// The article screen. Expects an [ArticleNarrationCubit] above it.
class PublishedArticleDetail extends StatelessWidget {
  final PublishedArticleEntity article;

  const PublishedArticleDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.l10n.back,
          icon: const Icon(Ionicons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ArticleNarrationCubit, ArticleNarrationState>(
        listener: _showWhenUnavailable,
        builder: _buildArticle,
      ),
    );
  }

  Widget _buildArticle(BuildContext context, ArticleNarrationState narration) {
    final progress = narration is ArticleNarrationReading ? narration.progress : null;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _buildHeader(context, narration),
        _buildThumbnail(),
        _buildContent(context, progress),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ArticleNarrationState narration) {
    final progress = narration is ArticleNarrationReading ? narration.progress : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.25)
                .merge(progress?.sentenceIndex == 0 ? readAloudHighlightStyle : null),
          ),
          const SizedBox(height: 12),
          PublishedArticleByline(article: article, showsReadingTime: true),
          const SizedBox(height: 16),
          ListenButton(
            isReading: narration is ArticleNarrationReading,
            onPressed: () => context.read<ArticleNarrationCubit>().toggleReading(article),
          ),
          if (progress != null) _buildProgressBar(progress),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ArticleNarrationProgressEntity progress) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress.fractionRead),
        duration: const Duration(milliseconds: 300),
        builder: (context, fractionRead, __) => LinearProgressIndicator(
          value: fractionRead,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
          semanticsLabel: context.l10n.readingProgress,
        ),
      ),
    );
  }

  void _showWhenUnavailable(BuildContext context, ArticleNarrationState state) {
    if (state is! ArticleNarrationUnavailable) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(context.l10n.cannotReadAloud),
    ));
  }

  Widget _buildThumbnail() {
    return Hero(
      tag: publishedArticleHeroTag(article),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(imageUrl: article.thumbnailUrl, fit: BoxFit.cover),
      ),
    );
  }

  /// The Markdown content, or the plain text following the voice while it is read aloud.
  Widget _buildContent(BuildContext context, ArticleNarrationProgressEntity? progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: progress == null
            ? _buildMarkdown(context)
            : FollowAlongText(key: const ValueKey('follow-along'), progress: progress),
      ),
    );
  }

  /// Selectable through a [SelectionArea] rather than `MarkdownBody.selectable`, which makes screen
  /// readers announce every paragraph as a text field.
  Widget _buildMarkdown(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SelectionArea(
      key: const ValueKey('markdown'),
      child: MarkdownBody(
        data: article.content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.6),
          h2: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          h3: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          listBullet: textTheme.bodyLarge?.copyWith(fontSize: 17),
        ),
      ),
    );
  }

}
