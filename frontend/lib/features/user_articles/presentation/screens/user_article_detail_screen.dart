import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/detail/user_article_detail_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/detail/user_article_detail_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_markup.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_text.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:share_plus/share_plus.dart';

class UserArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const UserArticleDetailScreen({super.key, required this.articleId});

  @override
  State<UserArticleDetailScreen> createState() =>
      _UserArticleDetailScreenState();
}

class _UserArticleDetailScreenState extends State<UserArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserArticleDetailCubit>().loadArticle(widget.articleId);
  }

  /// No public URL to share -- user_articles deliberately has no `url`
  /// field (see backend/docs/DB_SCHEMA.md, "What was deliberately left out
  /// of the entity"), since a self-authored article has no external source.
  /// Shares the content itself as text instead of a link.
  Future<void> _shareArticle(BuildContext context, UserArticleEntity article) {
    return SharePlus.instance.share(
      ShareParams(
        subject: article.title,
        text: '${article.title}\n\n${article.description}\n\n'
            '${articleBodyToPlainText(article.content)}\n\n'
            '${context.l10n.byAuthor(article.authorName)}',
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.deleteArticleTitle),
        content: Text(dialogContext.l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<UserArticleDetailCubit>().deleteArticle(widget.articleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserArticleDetailCubit, UserArticleDetailState>(
      listener: (context, state) {
        if (state is UserArticleDetailDeleted) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (state is UserArticleDetailLoaded) {
          return _buildLoaded(context, state.article);
        }
        if (state is UserArticleDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.genericError)),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, UserArticleEntity article) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        // No explicit icon colors: inherit appBarTheme.iconTheme.
        actions: [
          IconButton(
            tooltip: context.l10n.shareAction,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareArticle(context, article),
          ),
          IconButton(
            tooltip: context.l10n.editArticle,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/UserArticleForm',
                  arguments: article);
              if (context.mounted) {
                unawaited(context
                    .read<UserArticleDetailCubit>()
                    .loadArticle(widget.articleId));
              }
            },
          ),
          IconButton(
            tooltip: context.l10n.deleteArticleTitle,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImage(url: article.thumbnailURL),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    // Same scale as a NewsAPI story's title (article_detail.dart),
                    // so your own article reads with the same weight as any other.
                    style: theme.textTheme.displayLarge
                        ?.copyWith(fontSize: 30, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${context.l10n.byAuthor(article.authorName)} · '
                    '${DateFormat.yMMMd().format(article.createdAt)}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  ArticleBodyText(content: article.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
