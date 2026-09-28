import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comments_section.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/article_author_row.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Detail screen for one article, including its comments section.
class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  /// Local thumbnail picked in the editor. Shown instead of the network
  /// image so the create-article preview mirrors the published layout.
  final File? previewImageFile;

  /// Hides the save bookmark: a preview is not a persisted article yet.
  final bool hideSaveButton;

  const ArticleDetailsView({
    super.key,
    this.article,
    this.previewImageFile,
    this.hideSaveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: BlocListener<LocalArticleBloc, LocalArticlesState>(
        // Skip the initial load: it only reveals the current bookmark
        // state and must not toast. Later Done states follow a user
        // save/remove tap.
        listenWhen: (previous, current) =>
            previous is LocalArticlesDone || current is LocalArticlesError,
        listener: _onLocalStateChanged,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton:
              hideSaveButton ? null : _buildFloatingActionButton(),
        ),
      ),
    );
  }

  bool _isArticleSaved(LocalArticlesState state) {
    final current = article;
    final saved = state.articles;
    if (current == null || saved == null) return false;
    return saved.any((entry) => entry.isSameArticle(current));
  }

  void _onLocalStateChanged(BuildContext context, LocalArticlesState state) {
    if (state is LocalArticlesDone) {
      final saved = _isArticleSaved(state);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            saved ? 'Article saved successfully.' : 'Article removed.',
          ),
        ),
      );
    } else if (state is LocalArticlesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Could not save the article: ${state.message}'),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevronBack, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleAuthor(),
          _buildArticleImage(),
          _buildArticleDescription(),
          _buildComments(),
        ],
      ),
    );
  }

  /// Comments attach only to persisted articles. Preview drafts carry no
  /// id, so the section stays hidden until the article exists.
  Widget _buildComments() {
    final id = article?.id?.trim() ?? '';
    if (id.isEmpty) return const SizedBox.shrink();
    return CommentsSection(articleId: id);
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
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Ionicons.timeOutline, size: 16),
              const SizedBox(width: 4),
              Text(
                article?.publishedAt ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleAuthor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: ArticleAuthorRow(
        authorId: article?.authorId,
        authorDisplayName: article?.authorDisplayName,
        avatarRadius: 16,
        spacing: 10,
        nameStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        avatarCubitFactory: () => sl<AuthorAvatarCubit>(),
      ),
    );
  }

  Widget _buildArticleImage() {
    final previewFile = previewImageFile;
    if (previewFile != null) {
      return Container(
        width: double.maxFinite,
        height: 250,
        margin: const EdgeInsets.only(top: 14),
        child: Image.file(
          previewFile,
          fit: BoxFit.cover,
          cacheWidth: 1080,
        ),
      );
    }
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: article?.urlToImage != null
          ? Image.network(
              article!.urlToImage!,
              fit: BoxFit.cover,
              // Decode bound: full-width 250px hero; existing full-res
              // uploads must not decode at native resolution.
              cacheWidth: 1080,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        ),
        child: GptMarkdown(
          article?.content ?? '',
          // The package renders links but never launches them.
          onLinkTap: (url, _) => debugPrint('open $url'),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        final saved = _isArticleSaved(state);
        return FloatingActionButton(
          heroTag: 'articleDetailSave',
          onPressed: () => _onFloatingActionButtonPressed(context, saved),
          child: Icon(
            saved ? Ionicons.bookmark : Ionicons.bookmarkOutline,
            color: saved ? Colors.black : Colors.white,
          ),
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context, bool saved) {
    final current = article!;
    BlocProvider.of<LocalArticleBloc>(context).add(
      saved ? RemoveArticle(current) : SaveArticle(current),
    );
  }
}
