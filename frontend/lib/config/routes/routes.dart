import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/features/auth/presentation/pages/edit_profile/edit_profile_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login/login_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/register/register_page.dart';
import 'package:news_app_clean_architecture/features/home/presentation/pages/main_layout.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/create_article/create_article_page.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/edit_article/edit_article_page.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/saved_article/saved_article.dart';

/// Central route table: maps route names to pages.
class AppRoutes {
  /// Returns the page for [settings.name], falling back to [MainLayout].
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const MainLayout());

      case '/ArticleDetails':
        return _materialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/MyArticles':
        return _materialRoute(const MyArticlesPage());

      case '/CreateArticle':
        return _materialRoute(const CreateArticlePage());

      case '/EditArticle':
        final article = settings.arguments;
        if (article is ArticleEntity) {
          return _materialRoute(EditArticlePage(article: article));
        }
        return _materialRoute(const MyArticlesPage());

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/Register':
        return _materialRoute(const RegisterPage());

      case '/EditProfile':
        return _materialRoute(const EditProfilePage());

      default:
        return _materialRoute(const MainLayout());
    }
  }

  /// Wraps [view] in a [MaterialPageRoute].
  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
