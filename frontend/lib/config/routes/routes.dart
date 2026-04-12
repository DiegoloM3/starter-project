import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/profile/profile_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/add_news_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/edit_news_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';

class EditNewsArgs {
  final ArticleEntity article;
  final NewsSection? section;

  const EditNewsArgs({required this.article, this.section});
}

class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/ArticleDetails';
  static const String savedArticles = '/SavedArticles';
  static const String profile = '/Profile';
  static const String addNews = '/AddNews';
  static const String editNews = '/EditNews';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _materialRoute(const DailyNews());

      case articleDetails:
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case savedArticles:
        return _materialRoute(const SavedArticles());

      case profile:
        return _materialRoute(const ProfileScreen());

      case addNews:
        return _materialRoute(const AddNewsScreen());

      case editNews:
        final args = settings.arguments as EditNewsArgs;
        return _materialRoute(EditNewsScreen(
          article: args.article,
          section: args.section,
        ));

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
