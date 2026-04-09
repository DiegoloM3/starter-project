import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_articles/saved_articles.dart';
import 'package:news_app_clean_architecture/features/login/presentation/pages/login/login.dart';
import 'package:news_app_clean_architecture/features/login/presentation/pages/register/register.dart';

class AppRoutes {
  static List<GoRoute> get list => [
        GoRoute(
          path: Paths.initial.path,
          builder: (context, state) => const Scaffold(),
        ),
        GoRoute(
          name: Paths.login.name,
          path: Paths.login.path,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          name: Paths.register.name,
          path: Paths.register.path,
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          name: Paths.dailyNews.name,
          path: Paths.dailyNews.path,
          builder: (context, state) => const DailyNews(),
          routes: [
            GoRoute(
              name: Paths.savedArticles.name,
              path: Paths.savedArticles.path,
              builder: (context, state) => const SavedArticles(),
            ),
            GoRoute(
              name: Paths.articleDetails.name,
              path: Paths.articleDetails.path,
              builder: (context, state) {
                final article = state.extra! as ArticleEntity;

                return ArticleDetailsView(article: article);
              },
            ),
          ],
        ),
      ];
}
