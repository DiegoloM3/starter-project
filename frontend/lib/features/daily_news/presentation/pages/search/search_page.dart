import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/search/search_articles_bloc.dart';
import '../../bloc/article/search/search_articles_event.dart';
import '../../bloc/article/search/search_articles_state.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_article_tile.dart';

class SearchPage extends StatelessWidget {
  /// When `true`, hides the back button (used inside bottom nav shell).
  final bool embedded;

  const SearchPage({Key? key, this.embedded = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocProvider<SearchArticlesBloc>(
      create: (_) => sl<SearchArticlesBloc>(),
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLow,
        appBar: _buildAppBar(context),
        body: const Column(
          children: [
            _SearchField(),
            Expanded(child: _SearchResults()),
          ],
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
      leading: embedded
          ? null
          : IconButton(
              icon: Icon(Icons.chevron_left, color: cs.onSurface, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        AppLocalizations.of(context)!.searchTitle,
        style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: cs.outline),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: TextField(
        autofocus: false,
        style: tt.bodyMedium,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: tt.bodyMedium?.copyWith(color: cs.outlineVariant),
          prefixIcon:
              Icon(Icons.search, color: cs.outlineVariant, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
          filled: true,
          fillColor: cs.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: cs.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: cs.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
        onChanged: (query) {
          context.read<SearchArticlesBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SearchArticlesBloc, SearchArticlesState>(
      builder: (context, state) {
        if (state is SearchArticlesInitial) {
          return EmptyStateWidget(
            icon: Icons.search,
            title: l10n.searchPrompt,
            subtitle: l10n.searchPromptSubtitle,
          );
        }

        if (state is SearchArticlesLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => SkeletonArticleTile(showDivider: i < 4),
          );
        }

        if (state is SearchArticlesFailure) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            subtitle: state.error?.message ?? l10n.searchFailed,
            actionLabel: l10n.tryAgain,
            onAction: () {
              // Retry not directly possible without the query — user can
              // re-type in the field.
            },
          );
        }

        if (state is SearchArticlesDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: l10n.noArticlesFound,
              subtitle: l10n.tryDifferentKeywords,
            );
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleWidget(
                article: articles[index],
                showDivider: index < articles.length - 1,
                onArticlePressed: (article) =>
                    _onArticlePressed(context, article),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
