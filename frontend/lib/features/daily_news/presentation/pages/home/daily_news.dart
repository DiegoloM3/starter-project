import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/locale/locale_provider.dart';
import 'package:news_app_clean_architecture/shared/widgets/article_skeleton.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppbar(context),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
            tooltip: AppLocalizations.of(context).publishNewArticle,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.appTitle),
      actions: [
        _LanguageMenu(),
        IconButton(
          tooltip: l10n.myArticles,
          onPressed: () => Navigator.pushNamed(context, '/MyArticles'),
          icon: const Icon(Icons.library_books_outlined),
        ),
        IconButton(
          tooltip: l10n.savedArticles,
          onPressed: () => Navigator.pushNamed(context, '/SavedArticles'),
          icon: const Icon(Icons.bookmark),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, RemoteArticlesState state) {
    // Loading — shimmer.
    if (state is RemoteArticlesLoading) {
      return const ArticleSkeletonList(count: 6);
    }

    // Error — illustrated retry.
    if (state is RemoteArticlesError) {
      return _ErrorBody(
        onRetry: () =>
            context.read<RemoteArticlesBloc>().add(const GetArticles()),
      );
    }

    // Done — article list with featured first item.
    if (state is RemoteArticlesDone && state.articles != null) {
      return _ArticleList(
        articles: state.articles!,
        onArticlePressed: (a) =>
            Navigator.pushNamed(context, '/ArticleDetails', arguments: a),
        onRefresh: () async =>
            context.read<RemoteArticlesBloc>().add(const GetArticles()),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── ARTICLE LIST WITH FEATURED + PULL-TO-REFRESH ───────────────────────────

class _ArticleList extends StatelessWidget {
  final List<ArticleEntity> articles;
  final void Function(ArticleEntity) onArticlePressed;
  final Future<void> Function() onRefresh;

  const _ArticleList({
    required this.articles,
    required this.onArticlePressed,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Text(
          'No articles available',
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return ArticleWidget(
            article: articles[index],
            isFeatured: index == 0,
            onArticlePressed: (_) => onArticlePressed(articles[index]),
          );
        },
      ),
    );
  }
}

// ─── ERROR STATE ────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64, color: colors.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Could not load news',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LANGUAGE MENU ──────────────────────────────────────────────────────────

class _LanguageMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.locale?.languageCode;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.changeLanguage,
      onSelected: (code) {
        if (code == 'system') {
          localeProvider.clearLocale();
        } else {
          localeProvider.setLocale(Locale(code));
        }
      },
      itemBuilder: (_) => [
        _item('system', '🌐  ${l10n.languageSystem}', current == null),
        _item('en', '🇺🇸  ${l10n.languageEnglish}', current == 'en'),
        _item('es', '🇪🇸  ${l10n.languageSpanish}', current == 'es'),
      ],
    );
  }

  PopupMenuItem<String> _item(String value, String label, bool selected) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (selected) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }
}
