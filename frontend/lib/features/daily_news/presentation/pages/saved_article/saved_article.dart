import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class SavedArticles extends StatefulWidget {
  /// When `true`, hides the back button (used inside bottom nav shell).
  final bool embedded;

  /// When `true`, the tab is currently visible — triggers a refresh of saved
  /// articles so changes made on other screens (e.g. bookmark from detail) are
  /// picked up.
  final bool isActive;

  const SavedArticles({
    Key? key,
    this.embedded = false,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<SavedArticles> createState() => _SavedArticlesState();
}

class _SavedArticlesState extends State<SavedArticles> {
  late final LocalArticleBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<LocalArticleBloc>()..add(const GetSavedArticles());
  }

  @override
  void didUpdateWidget(covariant SavedArticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _bloc.add(const GetSavedArticles());
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocProvider<LocalArticleBloc>.value(
      value: _bloc,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          appBar: _buildAppBar(context),
          body: const _SavedBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: widget.embedded
          ? null
          : IconButton(
              icon: Icon(Icons.chevron_left,
                  color: cs.onSurface, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        AppLocalizations.of(context)!.savedArticles,
        style: tt.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: cs.outline),
      ),
    );
  }
}

class _SavedBody extends StatelessWidget {
  const _SavedBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

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
            actionLabel: l10n.tryAgain,
            onAction: () => context
                .read<LocalArticleBloc>()
                .add(const GetSavedArticles()),
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
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  color: cs.error,
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
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.articleRemoved),
        action: SnackBarAction(
          label: l10n.undo,
          textColor: cs.primary,
          onPressed: () {
            BlocProvider.of<LocalArticleBloc>(context)
                .add(SaveArticle(article));
          },
        ),
      ),
    );
  }
}
