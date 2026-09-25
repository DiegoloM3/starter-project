import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_toast.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/article.dart';
import '../bloc/article/local/local_article_bloc.dart';
import '../bloc/article/local/local_article_event.dart';
import '../bloc/article/local/local_article_state.dart';

/// Filled when the story is saved, outlined when it isn't; tapping toggles.
/// Compared by url: the feed's copy of a story has no database id, the
/// saved copy does (see ArticleRepositoryImpl).
class BookmarkButton extends StatelessWidget {
  final ArticleEntity article;
  final Color? color;

  /// A white icon in a dark circle, to sit on the corner of a photo.
  final bool onPhoto;

  const BookmarkButton({
    super.key,
    required this.article,
    this.color,
    this.onPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        final isSaved = state is LocalArticlesDone &&
            state.articles!.any((saved) => saved.url == article.url);
        return IconButton(
          tooltip:
              isSaved ? context.l10n.removeFromSaved : context.l10n.saveAction,
          color: onPhoto ? Colors.white : color,
          style: onPhoto
              ? IconButton.styleFrom(
                  backgroundColor: const Color(0x99000000),
                  minimumSize: const Size(36, 36),
                  padding: const EdgeInsets.all(6),
                  iconSize: 20,
                )
              : null,
          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
          onPressed: () => _toggle(context, isSaved),
        );
      },
    );
  }

  void _toggle(BuildContext context, bool isSaved) {
    final bloc = context.read<LocalArticleBloc>();
    if (isSaved) {
      bloc.add(RemoveArticle(article));
      AppToast.show(context, message: context.l10n.articleRemovedFromSaved);
    } else {
      bloc.add(SaveArticle(article));
      AppToast.show(context, message: context.l10n.articleSaved);
    }
  }
}

class ShareButton extends StatelessWidget {
  final ArticleEntity article;
  final Color? color;

  const ShareButton({super.key, required this.article, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.shareAction,
      color: color,
      icon: const Icon(Icons.share_outlined),
      onPressed: () => SharePlus.instance.share(
        ShareParams(
          subject: article.title,
          text: '${article.title}\n\n${article.url}',
        ),
      ),
    );
  }
}
