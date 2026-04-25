import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/auth':
        return _materialRoute(const AuthScreen());

      case '/forgot-password':
        return _materialRoute(const ForgotPasswordScreen());

      // New lowercase name + legacy name used by daily_news (do not remove)
      case '/article-details':
      case '/ArticleDetails':
        final article = settings.arguments;
        if (article is! ArticleEntity) return _materialRoute(const DailyNews());
        return _materialRoute(ArticleDetailsView(article: article));

      // New lowercase name + legacy name used by daily_news (do not remove)
      case '/saved-articles':
      case '/SavedArticles':
        return _materialRoute(const SavedArticles());
        
      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
