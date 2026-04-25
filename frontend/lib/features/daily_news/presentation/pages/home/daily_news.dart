import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/core/env/app_env.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text('Daily News'),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark),
          ),
        ),
      ],
    );
  }

  BlocBuilder<RemoteArticlesBloc, RemoteArticlesState> _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: _buildErrorState(context, state.failure),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, AppFailure failure) {
    final theme = context.appTheme;
    final missingKey = !AppEnv.hasNewsApiKey;
    final title = missingKey
        ? 'Missing NEWS_API_KEY'
        : 'Could not load the news feed';
    final detail = missingKey
        ? 'Run with --dart-define-from-file=keys.local.json '
            '(or use make run / the VS Code launch config).'
        : failure.when(
            network: (message, statusCode) =>
                [if (statusCode != null) '[$statusCode]', message ?? '']
                    .where((s) => s.isNotEmpty)
                    .join(' '),
            cache: (message) => message ?? 'Cache error',
            validation: (field, reason) => '$field: $reason',
            auth: (message) => message ?? 'Auth error',
            unknown: (cause, _) => cause?.toString() ?? 'Unknown error',
          );

    return Padding(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.onSurfaceMuted),
            SizedBox(height: theme.spacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.spacing.sm),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: theme.onSurfaceMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.spacing.lg),
            if (!missingKey)
              FilledButton.icon(
                onPressed: () => context
                    .read<RemoteArticlesBloc>()
                    .add(const GetArticles()),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesPage(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    final articleWidgets = <Widget>[];
    for (final article in articles) {
      articleWidgets.add(
        ArticleWidget(
          article: article,
          onArticlePressed: (article) => _onArticlePressed(context, article),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView(
        children: articleWidgets,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.myArticles()),
        icon: const Icon(Icons.edit_note),
        label: const Text('My Articles'),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    context.push(AppRoutes.articleDetailFor(article), extra: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    context.push(AppRoutes.saved());
  }
}
