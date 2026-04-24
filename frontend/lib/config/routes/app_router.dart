import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/article_editor/article_editor_page.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/pages/user_article_detail/user_article_detail_page.dart';

/// Top-level [GoRouter] used by `MaterialApp.router`.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home(),
  routes: [
    GoRoute(
      path: AppRoutes.home(),
      name: AppRoutes.homeName,
      builder: (context, state) => const DailyNews(),
    ),
    GoRoute(
      path: AppRoutes.saved(),
      name: AppRoutes.savedName,
      builder: (context, state) => const SavedArticles(),
    ),
    GoRoute(
      path: '/article/:id',
      name: AppRoutes.articleDetailName,
      builder: (context, state) {
        final article = state.extra as ArticleEntity?;
        return ArticleDetailsView(article: article);
      },
    ),
    GoRoute(
      path: AppRoutes.myArticles(),
      name: AppRoutes.myArticlesName,
      builder: (context, state) => const MyArticlesPage(),
      routes: [
        GoRoute(
          path: 'new',
          name: AppRoutes.articleEditorNewName,
          builder: (context, state) => const ArticleEditorPage(),
        ),
        GoRoute(
          path: ':id',
          name: AppRoutes.userArticleDetailName,
          builder: (context, state) {
            final article = state.extra as UserArticleEntity?;
            if (article == null) {
              return const _MissingArticlePage();
            }
            return UserArticleDetailPage(article: article);
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: AppRoutes.articleEditorEditName,
              builder: (context, state) {
                final article = state.extra as UserArticleEntity?;
                return ArticleEditorPage(editing: article);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class _MissingArticlePage extends StatelessWidget {
  const _MissingArticlePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Article not found')),
    );
  }
}
