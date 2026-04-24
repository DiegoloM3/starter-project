import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';

/// Top-level [GoRouter] used by `MaterialApp.router`.
///
/// Routes for `user_articles` (F6/F7) get appended here once they exist.
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
        // The id segment exists for deep-linking parity, but the entity is
        // currently passed via `extra` because NewsAPI articles have no
        // server-side id we can re-fetch by. F4 will swap this for a real
        // lookup against the local cache.
        final article = state.extra as ArticleEntity?;
        return ArticleDetailsView(article: article);
      },
    ),
  ],
);
