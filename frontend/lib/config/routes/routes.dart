import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/profile_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/register_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/publish_article/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/chatbot/owl_assistant_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/topics/topics_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/search/search_page.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const LoginPage());

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/DailyNews':
        return _materialRoute(const DailyNews());

      case '/Register':
        return _materialRoute(const RegisterPage());

      case '/Profile':
        return _materialRoute(const ProfilePage());

      case '/Topics':
        return _materialRoute(const TopicsPage());

      case '/Search':
        return _materialRoute(const SearchPage());

      case '/ArticleDetails':
        return _materialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());
      
      case '/PublishArticle':
        return _materialRoute(const PublishArticlePage());

      case '/OwlAssistant':
        return _materialRoute(const OwlAssistantPage());
        
      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
