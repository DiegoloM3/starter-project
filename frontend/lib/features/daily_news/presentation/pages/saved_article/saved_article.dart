import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_article_tile.dart';

class SavedArticles extends HookWidget {
  /// When `true`, hides the back button (used inside bottom nav shell).
  final bool embedded;

  const SavedArticles({Key? key, this.embedded = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.bg,
          appBar: _buildAppBar(context),
          body: const _SavedBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: embedded
          ? null
          : IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.t1, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        AppLocalizations.of(context)!.savedArticles,
        style: AppTypography.serif(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.t1,
          letterSpacing: -0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

class _SavedBody extends StatelessWidget {
  const _SavedBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (_, i) => SkeletonArticleTile(showDivider: i < 2),
          );
        }

        if (state is LocalArticlesFailure) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            subtitle: state.error.message,
          );
        }

        if (state is LocalArticlesDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: l10n.noSavedTitle,
              subtitle: l10n.noSavedSubtitle,
            );
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Dismissible(
                key: ValueKey(article.id ?? index),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.bookmark_remove,
                      color: Colors.white, size: 22),
                ),
                onDismissed: (_) => _onRemove(context, article),
                child: ArticleWidget(
                  article: article,
                  isRemovable: true,
                  showDivider: index < articles.length - 1,
                  onRemove: (a) => _onRemove(context, a),
                  onArticlePressed: (a) =>
                      Navigator.pushNamed(context, '/ArticleDetails',
                          arguments: a),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _onRemove(BuildContext context, ArticleEntity article) {
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.articleRemoved),
        action: SnackBarAction(
          label: l10n.undo,
          textColor: AppColors.red,
          onPressed: () {
            BlocProvider.of<LocalArticleBloc>(context)
                .add(SaveArticle(article));
          },
        ),
      ),
    );
  }
}
