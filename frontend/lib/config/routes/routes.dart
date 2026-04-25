import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/profile/profile.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/welcome/welcome.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/sign_in/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/sign_up/sign_up.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/pages/add_article/add_article.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/AddArticle':
        return _materialRoute(const AddArticlePage());

      case '/Welcome':
        return _materialRoute(const WelcomePage());

      case '/SignIn':
        return _materialRoute(const SignInPage());

      case '/SignUp':
        return _materialRoute(const SignUpPage());

      case '/Profile':
        return _materialRoute(const ProfileScreen());

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
