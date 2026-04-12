import 'package:flutter/material.dart';

import '../../features/articles_upload/domain/entities/article_upload.dart';
import '../../features/articles_upload/presentation/screens/login_screen.dart';
import '../../features/articles_upload/presentation/screens/onboarding_screen.dart';
import '../../features/articles_upload/presentation/screens/article_upload_detail_screen.dart';
import '../../features/articles_upload/presentation/screens/create_article_screen.dart';
import '../../features/articles_upload/presentation/screens/edit_article_screen.dart';
import '../../features/articles_upload/presentation/screens/my_articles_screen.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/DailyNews':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/MyArticles':
        return _materialRoute(const MyArticlesScreen());

      case '/CreateArticle':
        return _materialRoute(const CreateArticleScreen());

      case '/ArticleUploadDetail':
        return _materialRoute(
          ArticleUploadDetailScreen(
            article: settings.arguments as ArticleUploadEntity,
          ),
        );

      case '/Onboarding':
        return _materialRoute(const OnboardingScreen());

      case '/Login':
        return _materialRoute(const LoginScreen());

      case '/EditArticle':
        return _materialRoute(
          EditArticleScreen(
            article: settings.arguments as ArticleUploadEntity,
          ),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
